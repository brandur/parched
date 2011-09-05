#!/usr/bin/env rake
# Add your own tasks in files placed in lib/tasks ending in .rake,
# for example lib/tasks/capistrano.rake, and they will automatically be available to Rake.

require File.expand_path('../config/application', __FILE__)

Skine::Application.load_tasks

task :expire => :environment do
  controller    = PagesController.new
  expired_files = []
  revision      = ENV['REVISION'] || ENV['revision'] || 'master'

  repo   = Grit::Repo.new(App.repo)
  commit = repo.commits(revision, 1).first
  next unless commit

  repo.commit_diff(commit.id).each do |diff|
    expired_files.concat expire_file(controller, diff.a_path)
    # a_path will differ from b_path in case of a move
    expired_files.concat expire_file(controller, diff.b_path) if diff.a_path != diff.b_path
  end
  put_expired_files(expired_files)
end

task :expire_all => :environment do
  controller    = PagesController.new
  repo          = Grit::Repo.new(App.repo)
  expired_files = expire_tree(controller, repo.tree)
  put_expired_files(expired_files)
end

def expire_file(controller, path)
  path_without_ext = Skine::Repo.chomp_ext(path)
  controller.expire_page '/' + path
  controller.expire_page '/' + path_without_ext
  [path_without_ext, path]
end

def expire_tree(controller, tree, path = nil)
  expired_files = []
  tree.contents.each do |content|
    # Note that we keep track of the path manually because Grit itself does 
    # not keep track
    file = path ? File.join(path, content.name) : content.name
    if content.class == Grit::Tree
      expired_files.concat expire_tree(controller, content, file)
    else
      expired_files.concat expire_file(controller, file)
    end
  end
  expired_files
end

def put_expired_files(expired_files)
  puts "Files expired:" if expired_files.count > 0
  expired_files.sort.uniq.each do |expired_file|
    puts "* #{expired_file}"
  end
end
