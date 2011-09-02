module Skine
  module Filters
    class TexFilter
      def initialize
        @tex_map = {}
      end

      def extract(data)
        data.gsub(/\\\[\s*(.*?)\s*\\\]/m) do
          tag = CGI.escapeHTML($1)
          id  = Digest::SHA1.hexdigest(tag)
          @tex_map[id] = [:block, tag]
          id
        end.gsub(/\\\(\s*(.*?)\s*\\\)/m) do
          tag = CGI.escapeHTML($1)
          id  = Digest::SHA1.hexdigest(tag)
          @tex_map[id] = [:inline, tag]
          id
        end
      end

      def process(data)
        @tex_map.each do |id, spec|
          type, tex = *spec
          out =
          case type
            when :block
              %{<script type="math/tex; mode=display">#{tex}</script>}
            when :inline
              %{<script type="math/tex">#{tex}</script>}
          end
          data.gsub!(id, out)
        end
        data
      end
    end
  end
end
