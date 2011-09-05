require 'spec_helper'

describe PagesController do

  describe 'GET index' do

    it 'should redirect to #show' do
      get :index
      response.should redirect_to(:action => 'show', :path => 'index')
    end

  end

  describe 'GET show' do

    it 'renders a templated page (Markdown)' do
      Skine::Repo.any_instance.stub(:find).and_return(nil)
      Skine::Repo.any_instance.stub(:find_fuzzy).and_return mockb('my/git/page blob') { |blob|
        blob.should_receive(:name).at_least(1).and_return('my/git/page.md')
        blob.should_receive(:data).and_return("Hello!\n======\n\nThis is markdown!")
        blob.should_receive(:last_commit).and_return mockb('last_commit') { |last_commit|
          last_commit.should_receive(:author).and_return('spartacus')
          last_commit.should_receive(:sha).and_return('91b05dfb566203aff11f1539d690f07b01a98720')
        }
      }

      get :show, :path => 'my/git/page'

      assigns(:content).should eq("<h1>Hello!</h1>\n\n<p>This is markdown!</p>\n")
      assigns(:last_commit_author).should eq('spartacus')
      assigns(:last_commit_sha).should eq('91b05dfb566203aff11f1539d690f07b01a98720')
      assigns(:title).should eq('Hello!')
    end

    it 'sends a file on an exact page match' do
      Skine::Repo.any_instance.stub(:find).and_return mockb('paris.jpg') { |blob|
        blob.should_receive(:name).at_least(1).and_return('paris.jpg')
        blob.should_receive(:data).at_least(1).and_return("\0")
      }
      PagesController.any_instance.should_receive(:send_data)

      get :show, :path => 'my/git/page'
      
      response.should be_success
    end

    it 'sends a file on a non-template page' do
      Skine::Repo.any_instance.stub(:find).and_return(nil)
      Skine::Repo.any_instance.stub(:find_fuzzy).and_return mockb('my/git/page blob') { |blob|
        blob.should_receive(:name).at_least(1).and_return('my/git/page.xyz')
        blob.should_receive(:data).at_least(1).and_return("\0")
      }
      PagesController.any_instance.should_receive(:send_data)

      get :show, :path => 'my/git/page'

      response.should be_success
    end

    it 'sends a 404 for a path not in the repository' do
      Skine::Repo.any_instance.stub(:find).and_return(nil)
      Skine::Repo.any_instance.stub(:find_fuzzy).and_return(nil)

      expect{ get(:show, :path => 'my/git/page') }.should raise_error(ActiveRecord::RecordNotFound)
    end

    it 'sends a 404 for a partial' do
      Skine::Repo.any_instance.stub(:find).and_return(nil)
      Skine::Repo.any_instance.stub(:find_fuzzy).and_return mockb('my/_partial blob') { |blob|
        blob.should_receive(:name).and_return('_partial')
      }

      expect{ get(:show, :path => 'my/_partial') }.should raise_error(ActiveRecord::RecordNotFound)
    end

  end

  describe 'GET show_raw' do

    it 'sends a file on a template page' do
      Skine::Repo.any_instance.stub(:find).and_return(nil)
      Skine::Repo.any_instance.stub(:find_fuzzy).and_return mockb('my/git/page blob') { |blob|
        blob.should_receive(:name).at_least(1).and_return('my/git/page.md')
        blob.should_receive(:data).at_least(1).and_return("\0")
      }
      PagesController.any_instance.should_receive(:send_data)

      get :show_raw, :path => 'my/git/page'

      response.should be_success
    end

    it 'sends a file on a non-template page' do
      Skine::Repo.any_instance.stub(:find).and_return(nil)
      Skine::Repo.any_instance.stub(:find_fuzzy).and_return mockb('my/git/page blob') { |blob|
        blob.should_receive(:name).at_least(1).and_return('my/git/page.xyz')
        blob.should_receive(:data).at_least(1).and_return("\0")
      }
      PagesController.any_instance.should_receive(:send_data)

      get :show_raw, :path => 'my/git/page'

      response.should be_success
    end

  end

end
