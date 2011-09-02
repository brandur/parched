require "spec_helper"

describe PagesController do
  describe "routing" do

    it 'routes to #show' do
      get('/my/git/page').should route_to('pages#show', :path => 'my/git/page')
    end

    it 'routes to #show_raw' do
      get('/raw/my/git/page').should route_to('pages#show_raw', :path => 'my/git/page')
    end

  end
end
