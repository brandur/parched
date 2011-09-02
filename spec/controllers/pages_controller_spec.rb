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
        blob.should_receive(:name).and_return('my/git/page.md')
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

      #get(:show, :path => 'my/git/page').should raise_error#_raise(ActiveRecord::RecordNotFound)
      expect{ get(:show, :path => 'my/git/page') }.should raise_error(ActiveRecord::RecordNotFound)
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

=begin
  describe "GET index" do
    it "assigns all hellos as @hellos" do
      hello = Hello.create! valid_attributes
      get :index
      assigns(:hellos).should eq([hello])
    end
  end

  describe "GET show" do
    it "assigns the requested hello as @hello" do
      hello = Hello.create! valid_attributes
      get :show, :id => hello.id.to_s
      assigns(:hello).should eq(hello)
    end
  end

  describe "GET new" do
    it "assigns a new hello as @hello" do
      get :new
      assigns(:hello).should be_a_new(Hello)
    end
  end

  describe "GET edit" do
    it "assigns the requested hello as @hello" do
      hello = Hello.create! valid_attributes
      get :edit, :id => hello.id.to_s
      assigns(:hello).should eq(hello)
    end
  end

  describe "POST create" do
    describe "with valid params" do
      it "creates a new Hello" do
        expect {
          post :create, :hello => valid_attributes
        }.to change(Hello, :count).by(1)
      end

      it "assigns a newly created hello as @hello" do
        post :create, :hello => valid_attributes
        assigns(:hello).should be_a(Hello)
        assigns(:hello).should be_persisted
      end

      it "redirects to the created hello" do
        post :create, :hello => valid_attributes
        response.should redirect_to(Hello.last)
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved hello as @hello" do
        # Trigger the behavior that occurs when invalid params are submitted
        Hello.any_instance.stub(:save).and_return(false)
        post :create, :hello => {}
        assigns(:hello).should be_a_new(Hello)
      end

      it "re-renders the 'new' template" do
        # Trigger the behavior that occurs when invalid params are submitted
        Hello.any_instance.stub(:save).and_return(false)
        post :create, :hello => {}
        response.should render_template("new")
      end
    end
  end

  describe "PUT update" do
    describe "with valid params" do
      it "updates the requested hello" do
        hello = Hello.create! valid_attributes
        # Assuming there are no other hellos in the database, this
        # specifies that the Hello created on the previous line
        # receives the :update_attributes message with whatever params are
        # submitted in the request.
        Hello.any_instance.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => hello.id, :hello => {'these' => 'params'}
      end

      it "assigns the requested hello as @hello" do
        hello = Hello.create! valid_attributes
        put :update, :id => hello.id, :hello => valid_attributes
        assigns(:hello).should eq(hello)
      end

      it "redirects to the hello" do
        hello = Hello.create! valid_attributes
        put :update, :id => hello.id, :hello => valid_attributes
        response.should redirect_to(hello)
      end
    end

    describe "with invalid params" do
      it "assigns the hello as @hello" do
        hello = Hello.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Hello.any_instance.stub(:save).and_return(false)
        put :update, :id => hello.id.to_s, :hello => {}
        assigns(:hello).should eq(hello)
      end

      it "re-renders the 'edit' template" do
        hello = Hello.create! valid_attributes
        # Trigger the behavior that occurs when invalid params are submitted
        Hello.any_instance.stub(:save).and_return(false)
        put :update, :id => hello.id.to_s, :hello => {}
        response.should render_template("edit")
      end
    end
  end

  describe "DELETE destroy" do
    it "destroys the requested hello" do
      hello = Hello.create! valid_attributes
      expect {
        delete :destroy, :id => hello.id.to_s
      }.to change(Hello, :count).by(-1)
    end

    it "redirects to the hellos list" do
      hello = Hello.create! valid_attributes
      delete :destroy, :id => hello.id.to_s
      response.should redirect_to(hellos_url)
    end
  end
=end

end
