module Skine
  class Cache
    attr_reader :expired_files

    def initialize
      @expired_files = []
    end

    def expire_file(path)
      path_without_ext = Skine::Repo.chomp_ext(path)
      controller.expire_page '/' + path
      controller.expire_page '/' + path_without_ext
      expired_files.concat [path_without_ext, path]
      [path_without_ext, path]
    end

    def expire_tree(tree, path = nil)
      tree.contents.each do |content|
        # Note that we keep track of the path manually because Grit itself does 
        # not keep track
        file = path ? File.join(path, content.name) : content.name
        if content.class == Grit::Tree
          expire_tree(content, file)
        else
          expire_file(file)
        end
      end
    end

    def put_expired_files
      puts "Files expired:" if expired_files.count > 0
      expired_files.sort.uniq.each do |expired_file|
        puts "* #{expired_file}"
      end
      Rails.logger.info "Expired files: #{expired_files}"
    end

    private

    def controller
      @controller ||= ApplicationController.new
    end
  end
end
