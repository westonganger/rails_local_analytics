require 'spec_helper'

RSpec.describe RailsLocalAnalytics::DashboardController, type: :request do
  context "index" do
    it "renders" do
      skip "TODO"
      get rails_local_analytics.root_path
      expect(response.status).to eq(200)
    end
  end
end
