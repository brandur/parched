require 'parched/filters/code_filter'
require 'parched/filters/partial_filter'
require 'parched/filters/tag_filter'
require 'parched/filters/tex_filter'

module Parched
  class Page
    attr_reader :klass, :repo

    def initialize(repo, klass, data)
      @data    = data
      @klass   = klass
      @repo    = repo

      # Filter code was written with heavy inspiration from GitHub's Gollum
      @filters = [
        Parched::Filters::CodeFilter.new, 
        Parched::Filters::PartialFilter.new(self), 
        Parched::Filters::TagFilter.new(self), 
        Parched::Filters::TexFilter.new, 
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
