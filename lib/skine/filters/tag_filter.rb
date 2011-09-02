require 'digest/sha1'

module Skine
  module Filters
    class TagFilter
      def initialize(page)
        @page    = page
        @tag_map = {}
      end

      def extract(data)
        data.gsub!(/(.?)\[\[(.+?)\]\]([^\[]?)/m) do
          if $1 == "'" && $3 != "'"
            "[[#{$2}]]#{$3}"
          else
            id = Digest::SHA1.hexdigest($2)
            @tag_map[id] = $2
            "#{$1}#{id}#{$3}"
          end
        end
        data
      end

      def process(data)
        @tag_map.each do |id, tag|
          data.gsub!(id, process_tag(tag))
        end
        data
      end

      private

      include ActionView::Helpers::UrlHelper

      def process_tag(tag)
        process_page_link_tag(tag)
      end

      def process_page_link_tag(tag)
        parts = tag.split('|')
        parts.reverse! if @page.klass == Tilt::WikiClothTemplate
        path, title = *parts.compact.map(&:strip)

        if path =~ %r{^https?://}
          link_to(title || path, path)
        else
          page     = @page.repo.find_fuzzy(path)
          presence = page ? 'present' : 'absent'
          link_to(title || path, "/#{path}", :class => "internal #{presence}")
        end
      end
    end
  end
end
