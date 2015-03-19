require 'rails_helper'

RSpec.describe "cluster_configurations/new", :type => :view do
  before(:each) do
    assign(:cluster_configuration, ClusterConfiguration.new())
  end

  it "renders new cluster_configuration form" do
    render

    assert_select "form[action=?][method=?]", cluster_configurations_path, "post" do
    end
  end
end
