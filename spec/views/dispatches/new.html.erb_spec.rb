require 'rails_helper'

RSpec.describe "dispatches/new", :type => :view do
  before(:each) do
    assign(:dispatch, Dispatch.new())
  end

  it "renders new dispatch form" do
    render

    assert_select "form[action=?][method=?]", dispatches_path, "post" do
    end
  end
end
