require 'spec_helper'

require 'skine'

describe Skine::Page do
  before(:each) do
    @repo  = mock('repo')
  end

  it 'should pass data through' do
    render('Hello, world!').should == 'Hello, world!'
  end

  describe Skine::Filters::TagFilter do
    include ActionView::Helpers::UrlHelper

    it 'should replace absent tags' do
      @repo.should_receive(:find_fuzzy).once.with('an-absent-link')
      render('Here is [[an-absent-link]].').should == 
        "Here is #{link_to 'an-absent-link', '/an-absent-link', :class => 'internal absent'}."
    end

    it 'should replace present tags' do
      @repo.should_receive(:find_fuzzy).once.with('a-present-link').and_return(mock('page'))
      render('Here is [[a-present-link]].').should == 
        "Here is #{link_to 'a-present-link', '/a-present-link', :class => 'internal present'}."
    end

    it 'should respect titled tags' do
      @repo.should_receive(:find_fuzzy).once.with('a-named-link')
      render('Here is [[a-named-link|A named link]].').should == 
        "Here is #{link_to 'A named link', '/a-named-link', :class => 'internal absent'}."
    end

    it 'should respect reversed titled tags for WikiCloth' do
      @repo.should_receive(:find_fuzzy).once.with('a-named-link')
      render('Here is [[A named link|a-named-link]].', :template_klass => Tilt::WikiClothTemplate).strip.should == 
        "<p>Here is #{link_to 'A named link', '/a-named-link', :class => 'internal absent'}.</p>"
    end

    it 'should allow tags with external links' do
      render('Here is [[http://rubyonrails.org]].').should == 
        "Here is #{link_to 'http://rubyonrails.org', 'http://rubyonrails.org'}."
    end

    it 'should allow tags with titled external links' do
      render('Here is [[http://rubyonrails.org|Ruby on Rails]].').should == 
        "Here is #{link_to 'Ruby on Rails', 'http://rubyonrails.org'}."
    end
  end

  # Shortcut for initialization and rendering
  def render(data, opts = {})
    opts = { :template_klass => Tilt::StringTemplate }.merge(opts)
    Skine::Page.new(@repo, opts[:template_klass], data).render
  end
end
