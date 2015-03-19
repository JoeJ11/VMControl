require 'rails_helper'

RSpec.describe "Dispatches", :type => :request do
  describe "GET /dispatches" do
    it "works! (now write some real specs)" do
      get dispatches_path
      expect(response).to have_http_status(200)
    end
  end
end
