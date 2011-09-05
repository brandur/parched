require 'skine'

desc 'Expire cache for all files included in a commit, use revision= (defaults to HEAD)'
task :expire => :environment do
  revision = ENV['REVISION'] || ENV['revision'] || 'master'

  repo   = Grit::Repo.new(App.repo)
  commit = repo.commits(revision, 1).first
  next unless commit

  cache = Skine::Cache.new
  repo.commit_diff(commit.id).each do |diff|
    cache.expire_file(diff.a_path)
    # a_path will differ from b_path in case of a move
    cache.expire_file(diff.b_path) if diff.a_path != diff.b_path
  end
  cache.put_expired_files
end

desc 'Expire cache for all files in the repository'
task :expire_all => :environment do
  cache = Skine::Cache.new
  repo  = Grit::Repo.new(App.repo)
  cache.expire_tree(repo.tree)
  cache.put_expired_files
end

