require 'digest/sha1'

module Skine
  module Filters
    # With significant inspiration from Gollum.
    class TagFilter
      def initialize(page)
        @page    = page
        @tag_map = {}
      end

      # Extract all tags into the tagmap and replace with placeholders.
      #
      # data - The raw String data.
      #
      # Returns the placeholder'd String data.
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

      # Process all tags from the tagmap and replace the placeholders with the
      # final markup.
      #
      # data - The String data (with placeholders).
      #
      # Returns the marked up String data.
      def process(data)
        @tag_map.each do |id, tag|
          data.gsub!(id, process_tag(tag))
        end
        data
      end

      private

      include ActionView::Helpers::UrlHelper

      # Process a single tag into its final HTML form.
      #
      # tag       - The String tag datas (the stuff inside the double
      #             brackets).
      #
      # Returns the String HTML version of the tag.
      def process_tag(tag)
        process_page_link_tag(tag)
      end

      # Attempt to process the tag as a page link tag.
      #
      # tag       - The String tag datas (the stuff inside the double
      #             brackets).
      #
      # Returns the String HTML if the tag is a valid page link tag or nil
      #   if it is not.
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
