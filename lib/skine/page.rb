require 'skine/filters/tag_filter'

module Skine
  class Page
    attr_reader :klass, :repo

    def initialize(repo, klass, data)
      @data    = data
      @klass   = klass
      @repo    = repo

      @filters = [
        Skine::Filters::TagFilter.new(self)
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
