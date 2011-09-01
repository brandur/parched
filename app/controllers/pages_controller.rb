class PagesController < ApplicationController
  def index
    redirect_to '/index'
  end

  def show
    repo = Grit::Repo.new(App.repo)
    blob, path = find_blob(repo, params[:path])

    # Comes back as nil for an invalid path
    raise ActiveRecord::RecordNotFound unless blob

    # Tilt[] gets an appropriate template class given a file
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

    # Try a fuzzy match (against any extension)
    blob, path = find_fuzzy_blob(repo, path) unless blob

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
    return blob, content_path
  end
end
