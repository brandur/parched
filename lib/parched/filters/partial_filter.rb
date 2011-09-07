require 'digest/sha1'

module Parched
  module Filters
    class PartialFilter
      def initialize(page)
        @page        = page
        @partial_map = {}
      end

      def extract(data)
        data.gsub!(/(.?)\{\{(.+?)\}\}([^\[]?)/m) do
          if $1 == "'" && $3 != "'"
            "{{#{$2}}}#{$3}"
          else
            id = Digest::SHA1.hexdigest($2)
            @partial_map[id] = $2
            "#{$1}#{id}#{$3}"
          end
        end
        data
      end

      def process(data)
        @partial_map.each do |id, partial|
          blob = @page.repo.find(partial)
          blob = @page.repo.find_fuzzy(partial) unless blob

          out = if blob
            # Tilt[] gets an appropriate template class given a file
            klass = Tilt[blob.name]
            Parched::Page.new(@page.repo, klass, blob.data).render
          else
            %{{{Partial not found: "#{partial}"}}}
          end
          data.gsub!(id, out)
        end
        data
      end
    end
  end
end
