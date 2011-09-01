require 'digest/sha1'

module Skine
  # With significant inspiration from Gollum.
  class Page
    include ActionView::Helpers::UrlHelper

    def initialize(repo, klass, data)
      @data    = data
      @klass   = klass
      @repo    = repo
      @tag_map = {}
    end

    def render
      data = @data
      data = extract_tags(data)
      data = @klass.new{data}.render
      data = process_tags(data)
      data
    end

    private

    #########################################################################
    #
    # Tags
    #
    #########################################################################

    # Extract all tags into the tagmap and replace with placeholders.
    #
    # data - The raw String data.
    #
    # Returns the placeholder'd String data.
    def extract_tags(data)
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
    def process_tags(data)
      @tag_map.each do |id, tag|
        data.gsub!(id, process_tag(tag))
      end
      data
    end

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
      parts.reverse! if @klass == Tilt::WikiClothTemplate
      path, title = *parts.compact.map(&:strip)

      if path =~ %r{^https?://}
        link_to(title || path, path)
      else
        page     = @repo.find_fuzzy(path)
        presence = page ? 'present' : 'absent'
        link_to(title || path, "/#{path}", :class => "internal #{presence}")
      end
    end
  end
end
