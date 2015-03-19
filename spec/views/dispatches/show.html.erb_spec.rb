require 'rails_helper'

RSpec.describe "dispatches/show", :type => :view do
  before(:each) do
    @dispatch = assign(:dispatch, Dispatch.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
