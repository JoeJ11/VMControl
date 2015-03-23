require "rails_helper"

RSpec.describe DispatchesController, :type => :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/dispatches").to route_to("dispatches#index")
    end

    it "routes to #new" do
      expect(:get => "/dispatches/new").to route_to("dispatches#new")
    end

    it "routes to #show" do
      expect(:get => "/dispatches/1").to route_to("dispatches#show", :id => "1")
    end

    it "routes to #edit" do
      expect(:get => "/dispatches/1/edit").to route_to("dispatches#edit", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/dispatches").to route_to("dispatches#create")
    end

    it "routes to #update" do
      expect(:put => "/dispatches/1").to route_to("dispatches#update", :id => "1")
    end

    it "routes to #destroy" do
      expect(:delete => "/dispatches/1").to route_to("dispatches#destroy", :id => "1")
    end

  end
end
