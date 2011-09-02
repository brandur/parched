require 'spec_helper'

require 'skine'

describe Skine::Page do
  before(:each) do
    @repo  = mock('repo')
  end

  it 'should pass data through' do
    render('Hello, world!').should == 'Hello, world!'
  end

  #########################################################################
  #
  # Code
  #
  #########################################################################

  describe Skine::Filters::CodeFilter do
    it 'should render code without a language' do
      render("```\nputs 'Hello, world!'\n```").should == 
        %{<pre><code>puts 'Hello, world!'</code></pre>}
    end

    it 'should render code with a language' do
      render("``` ruby\nputs 'Hello, world!'\n```").should == 
        %{<pre><code class="language-ruby">puts 'Hello, world!'</code></pre>}
    end
  end

  #########################################################################
  #
  # Tags
  #
  #########################################################################

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

  #########################################################################
  #
  # TeX
  #
  #########################################################################

  describe Skine::Filters::TexFilter do
    it 'should render TeX block syntax' do
      render('a \[ a^2 \] b').should == 'a <script type="math/tex; mode=display">a^2</script> b'
    end

    it 'should render TeX inline syntax' do
      render('a \( a^2 \) b').should == 'a <script type="math/tex">a^2</script> b'
    end
  end

  # Shortcut for initialization and rendering
  def render(data, opts = {})
    opts = { :template_klass => Tilt::StringTemplate }.merge(opts)
    Skine::Page.new(@repo, opts[:template_klass], data).render
  end
end