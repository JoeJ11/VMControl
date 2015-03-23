require 'rails_helper'

RSpec.describe "cluster_configurations/edit", :type => :view do
  before(:each) do
    @cluster_configuration = assign(:cluster_configuration, ClusterConfiguration.create!())
  end

  it "renders the edit cluster_configuration form" do
    render

    assert_select "form[action=?][method=?]", cluster_configuration_path(@cluster_configuration), "post" do
    end
  end
end
