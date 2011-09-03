require 'spec_helper'

describe "pages/show.html.slim" do
  # Minimal set of variables to ensure a successful render
  before do
    @content = 'Hello, world!'
    @last_commit_author = 'spartacus'
    @last_commit_sha    = '91b05dfb566203aff11f1539d690f07b01a98720'
  end

  it 'renders for content without a layout' do
    @content = 'Hello with no layout.'
    render
    rendered.should have_selector('div.row')
  end

  it 'renders for content with a layout' do
    @content = <<-eos
      <div class="row">
        <div class="col12">
          Hello with a layout.
        </div>
      </div>
    eos
    render
    rendered.should have_selector('div.row')
  end
end
