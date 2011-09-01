class PagesController < ApplicationController
  caches_page :show, :show_raw

  def index
    redirect_to '/index'
  end

  def show
    repo = Grit::Repo.new(App.repo)
    blob, path = find_blob(repo, params[:path])

    # Exact match, send file as is
    send_blob(blob) && return if blob

    # No exact match, try to locate a file with this name and any extension, 
    # which we will render and return to the user
    blob, path = find_fuzzy_blob(repo, params[:path]) unless blob

    # Comes back as nil for an invalid path
    raise ActiveRecord::RecordNotFound unless blob

    # Tilt[] gets an appropriate template class given a file
    # @todo: send raw if there's no available template
    klass = Tilt[blob.name] || Tilt::StringTemplate
    @content = klass.new{ blob.data }.render

    last_commit = repo.log('master', path, :max_count => 1).first
    @last_commit_author = last_commit.author
    @last_commit_sha    = last_commit.sha
  end

  def show_raw
    repo = Grit::Repo.new(App.repo)
    blob, path = find_blob(repo, params[:path])

    # Comes back as nil for an invalid path
    raise ActiveRecord::RecordNotFound unless blob

    @content = blob.data
  end

  private

  def chomp_ext(file)
    file.chomp(File.extname(file))
  end

  def find_blob(repo, path)
    blob = repo.tree / path

    return blob, path if blob && blob.class == Grit::Blob 

    # Don't allow access to a tree (directory)
    return nil, nil
  end

  def find_fuzzy_blob(repo, path)
    blob, content_path = nil, nil
    parent = Pathname.new(path).parent.to_s
    parent = parent == '.' ? repo.tree : repo.tree / parent
    if parent
      parent.contents.each do |content|
        content_path = if parent.name != nil 
          (Pathname.new(parent.name) + content.name).to_s 
        else
          content.name
        end
        if chomp_ext(content_path) == path
          blob = content
          break
        end
      end
    end

    return blob, content_path if blob && blob.class == Grit::Blob 

    # Don't allow access to a tree (directory)
    return nil, nil
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
