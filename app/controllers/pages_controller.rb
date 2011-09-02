require 'skine'

class PagesController < ApplicationController
  caches_page :show, :show_raw

  def index
    redirect_to '/index'
  end

  def show
    repo = Skine::Repo.new(App.repo)
    blob = repo.find(params[:path])

    # Exact match, send file as is
    send_blob(blob) && return if blob

    # No exact match, try to locate a file with this name and any extension, 
    # which we will render and return to the user
    blob = repo.find_fuzzy(params[:path]) unless blob

    # Comes back as nil for an invalid path
    raise ActiveRecord::RecordNotFound unless blob

    # Tilt[] gets an appropriate template class given a file
    klass = Tilt[blob.name]

    # If there's no template class available, just send the raw version
    send_blob(blob) && return unless klass

    @content = Skine::Page.new(repo, klass, blob.data).render
    @title = extract_header(@content)

    last_commit = blob.last_commit
    @last_commit_author = last_commit.author
    @last_commit_sha    = last_commit.sha
  end

  def show_raw
    repo = Skine::Repo.new(App.repo)
    blob = repo.find(params[:path]) || repo.find_fuzzy(params[:path])

    # Comes back as nil for an invalid path
    raise ActiveRecord::RecordNotFound unless blob

    send_blob(blob)
  end

  private

  def extract_header(content)
    /<h1>(.*?)<\/h1>/im =~ content ? $1.strip : nil
  end

  def lookup_mime_type(file)
    Mime::Type.lookup_by_extension(File.extname(file)[1..-1])
  end

  def send_blob(blob)
    opts = { :filename => blob.name, :disposition => 'inline' }
    mime_type = lookup_mime_type(blob.name)
    opts[:type] = mime_type if mime_type
    send_data(blob.data, opts)
  end
end
