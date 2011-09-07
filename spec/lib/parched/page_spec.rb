require 'spec_helper'

require 'parched'

describe Parched::Page do
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

  describe Parched::Filters::CodeFilter do
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
  # Partials
  #
  #########################################################################

  describe Parched::Filters::PartialFilter do
    it 'should render partials' do
      @repo.should_receive(:find).once.with('my/_partial').and_return mockb('my/_partial blob') { |blob|
        blob.should_receive(:name).and_return('_partial')
        blob.should_receive(:data).and_return('my partial')
      }
      render('Here is {{my/_partial}}.').should == 
        "Here is my partial."
    end

    it 'should render partials that have a template' do
      @repo.should_receive(:find).once.with('my/_partial')
      @repo.should_receive(:find_fuzzy).once.with('my/_partial').and_return mockb('my/_partial.md blob') { |blob|
        blob.should_receive(:name).and_return('_partial.md')
        blob.should_receive(:data).and_return('My partial with **strong text**.')
      }
      render('Here is: {{my/_partial}}').should == 
        "Here is: <p>My partial with <strong>strong text</strong>.</p>\n"
    end

    it 'should render other filters within partials' do
      @repo.should_receive(:find).once.with('my/_partial').and_return mockb('my/_partial blob') { |blob|
        blob.should_receive(:name).and_return('_partial')
        blob.should_receive(:data).and_return("```\nputs 'Hello, world!'\n```")
      }
      render('Here is a hello, world example in Ruby: {{my/_partial}}').should == 
        %{Here is a hello, world example in Ruby: <pre><code>puts 'Hello, world!'</code></pre>}
    end
    
    it 'should render placeholder text for a missing partial' do
      @repo.should_receive(:find).once.with('my/_partial')
      @repo.should_receive(:find_fuzzy).once.with('my/_partial')
      render('Here is {{my/_partial}}.').should == 
        %{Here is {{Partial not found: "my/_partial"}}.}
    end

    it 'should recognize an escaped partial control sequence' do
      render("Here is '{{my/_partial}}.").should == "Here is {{my/_partial}}."
    end
  end

  #########################################################################
  #
  # Tags
  #
  #########################################################################

  describe Parched::Filters::TagFilter do
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

    it 'should recognize an escaped tag control sequence' do
      render("Here is '[[http://rubyonrails.org|Ruby on Rails]].").should == 
        "Here is [[http://rubyonrails.org|Ruby on Rails]]."
    end
  end

  #########################################################################
  #
  # TeX
  #
  #########################################################################

  describe Parched::Filters::TexFilter do
    before do
      App.stub(:enable_math).and_return(true)
    end

    it 'should render TeX block syntax' do
      render('a \[ a^2 \] b').should == 'a <script type="math/tex; mode=display">a^2</script> b'
    end

    it 'should render TeX inline syntax' do
      render('a \( a^2 \) b').should == 'a <script type="math/tex">a^2</script> b'
    end

    it 'should leave TeX alone when math is disabled' do
      App.stub(:enable_math).and_return(false)
      render('a \[ a^2 \] b').should == 'a [ a^2 ] b'
    end
  end

  # Shortcut for initialization and rendering
  def render(data, opts = {})
    opts = { :template_klass => Tilt::StringTemplate }.merge(opts)
    Parched::Page.new(@repo, opts[:template_klass], data).render
  end
end
