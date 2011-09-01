module Skine
  class Repo
    def initialize(repo_path)
      @repo = Grit::Repo.new(repo_path)
    end

    def find(path)
      blob = @repo.tree / path
      return_blob(blob, path)
    end

    def find_fuzzy(path)
      blob, content_path = nil, nil
      parent = Pathname.new(path).parent.to_s
      parent = parent == '.' ? @repo.tree : @repo.tree / parent
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
      return_blob(blob, content_path)
    end
    
    private

    def chomp_ext(file)
      file.chomp(File.extname(file))
    end

    def return_blob(blob, path)
      if blob && blob.class == Grit::Blob 
        Skine::Blob.new(blob, :path => path) 
      else
        # Don't allow access to a tree (directory)
        nil
      end
    end
  end
end
