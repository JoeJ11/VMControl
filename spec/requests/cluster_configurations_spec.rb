require 'rails_helper'

RSpec.describe "ClusterConfigurations", :type => :request do
  describe "GET /cluster_configurations" do
    it "works! (now write some real specs)" do
      get cluster_configurations_path
      expect(response).to have_http_status(200)
    end
  end
end
