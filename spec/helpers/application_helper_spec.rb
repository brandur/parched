require 'spec_helper'

describe ApplicationHelper do

  describe 'partial_page' do

    it 'should render partials' do
      Parched::Repo.any_instance.should_receive(:find).and_return mockb('my/_partial blob') { |blob|
        blob.should_receive(:name).and_return('my/_partial')
        blob.should_receive(:data).and_return('Hello from a partial!')
      }

      partial_page('my/_partial').should == 'Hello from a partial!'
    end

    it 'should render partials that have a template' do
      Parched::Repo.any_instance.should_receive(:find)
      Parched::Repo.any_instance.should_receive(:find_fuzzy).and_return mockb('my/_partial blob') { |blob|
        blob.should_receive(:name).and_return('my/_partial.md')
        blob.should_receive(:data).and_return('Hello from a partial!')
      }

      partial_page('my/_partial').should == "<p>Hello from a partial!</p>\n"
    end

    it "should raise an error when given a partial that doesn't exist" do
      Parched::Repo.any_instance.should_receive(:find)
      Parched::Repo.any_instance.should_receive(:find_fuzzy)

      expect{ partial_page('my/_partial') }.should raise_error
    end

  end

end
