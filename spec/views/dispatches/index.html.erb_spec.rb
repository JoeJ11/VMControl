require 'rails_helper'

RSpec.describe "dispatches/index", :type => :view do
  before(:each) do
    assign(:dispatches, [
      Dispatch.create!(),
      Dispatch.create!()
    ])
  end

  it "renders a list of dispatches" do
    render
  end
end
