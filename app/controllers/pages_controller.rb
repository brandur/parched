class PagesController < ApplicationController
  def index
  end

  def show
    repo = Grit::Repo.new(App.repo)
    blob = repo.tree / params[:path]

    # Comes back as nil for an invalid path
    raise ActiveRecord::RecordNotFound unless blob

    # Tilt[] gets an appropriate template class given a file
    klass = Tilt[params[:path]] || Tilt::StringTemplate
    @content = klass.new{ blob.data }.render

    last_commit = repo.log('master', params[:path], :max_count => 1).first
    @last_commit_author = last_commit.author
    @last_commit_sha    = last_commit.sha
  end
end
