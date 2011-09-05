require 'skine/filters/code_filter'
require 'skine/filters/partial_filter'
require 'skine/filters/tag_filter'
require 'skine/filters/tex_filter'

module Skine
  class Page
    attr_reader :klass, :repo

    def initialize(repo, klass, data)
      @data    = data
      @klass   = klass
      @repo    = repo

      # Filter code was written with heavy inspiration from GitHub's Gollum
      @filters = [
        Skine::Filters::CodeFilter.new, 
        Skine::Filters::PartialFilter.new(self), 
        Skine::Filters::TagFilter.new(self), 
        Skine::Filters::TexFilter.new, 
      ].freeze
    end

    def render
      data = @data
      @filters.each {|filter| data = filter.extract(data)}
      data = @klass ? @klass.new{data}.render : data
      @filters.each {|filter| data = filter.process(data)}
      data
    end
  end
end
