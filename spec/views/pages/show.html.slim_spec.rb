require 'spec_helper'

describe "pages/show.html.slim" do
  it "renders" do
    @content = 'Hello, world!'
    @last_commit_author = 'spartacus'
    @last_commit_sha    = '91b05dfb566203aff11f1539d690f07b01a98720'
    render
  end
end
