require 'rails_helper'

RSpec.describe "cluster_configurations/index", :type => :view do
  before(:each) do
    assign(:cluster_configurations, [
      ClusterConfiguration.create!(),
      ClusterConfiguration.create!()
    ])
  end

  it "renders a list of cluster_configurations" do
    render
  end
end
