module ApplicationHelper
  def partial_page(path)
    repo = Skine::Repo.new(App.repo)
    blob = repo.find(path)
    blob = repo.find_fuzzy(path) unless blob

    raise Error unless blob

    # Tilt[] gets an appropriate template class given a file
    klass = Tilt[blob.name]
    Skine::Page.new(repo, klass, blob.data).render
  end
end
