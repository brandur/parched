module Parched
  module Filters
    class CodeFilter
      def initialize
        @code_map = {}
      end

      def extract(data)
        data.gsub!(/^``` ?([^\r\n]+)?\r?\n(.+?)\r?\n```\r?$/m) do
          id = Digest::SHA1.hexdigest("#{$1}.#{$2}")
          @code_map[id] = { :lang => $1, :code => $2 }
          id
        end
        data
      end

      def process(data)
        @code_map.each do |id, spec|
          out = if spec[:lang]
            %{<pre><code class="language-#{spec[:lang].downcase}">#{spec[:code]}</code></pre>}
          else
            %{<pre><code>#{spec[:code]}</code></pre>}
          end
          data.gsub!(id, out)
        end
        data
      end
    end
  end
end
