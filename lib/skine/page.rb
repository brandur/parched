require 'skine/filters/code_filter'
require 'skine/filters/tag_filter'
require 'skine/filters/tex_filter'

module Skine
  class Page
    attr_reader :klass, :repo

    def initialize(repo, klass, data)
      @data    = data
      @klass   = klass
      @repo    = repo

      @filters = [
        Skine::Filters::CodeFilter.new, 
        Skine::Filters::TagFilter.new(self), 
        Skine::Filters::TexFilter.new, 
      ].freeze
    end

    def render
      data = @data
      @filters.each {|filter| data = filter.extract(data)}
      data = @klass.new{data}.render
      @filters.each {|filter| data = filter.process(data)}
      data
    end
  end
end
