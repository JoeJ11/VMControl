require "rails_helper"

RSpec.describe ClusterConfigurationsController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/cluster_configurations").to route_to("cluster_configurations#index")
    end

    it "routes to #new" do
      expect(:get => "/cluster_configurations/new").to route_to("cluster_configurations#new")
    end

    it "routes to #show" do
      expect(:get => "/cluster_configurations/1").to route_to("cluster_configurations#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/cluster_configurations/1/edit").to route_to("cluster_configurations#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/cluster_configurations").to route_to("cluster_configurations#create")
    end

    it "routes to #update" do
      expect(:put => "/cluster_configurations/1").to route_to("cluster_configurations#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/cluster_configurations/1").to route_to("cluster_configurations#destroy", :id => "1")
    end

  end
end
