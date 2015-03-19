require 'rails_helper'

RSpec.describe "dispatches/edit", :type => :view do
  before(:each) do
    @dispatch = assign(:dispatch, Dispatch.create!())
  end

  it "renders the edit dispatch form" do
    render

    assert_select "form[action=?][method=?]", dispatch_path(@dispatch), "post" do
    end
  end
end
