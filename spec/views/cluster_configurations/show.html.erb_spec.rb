require 'rails_helper'

RSpec.describe "cluster_configurations/show", :type => :view do
  before(:each) do
    @cluster_configuration = assign(:cluster_configuration, ClusterConfiguration.create!())
  end

  it "renders attributes in <p>" do
    render
  end
end
