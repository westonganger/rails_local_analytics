require 'spec_helper'

RSpec.describe RailsLocalAnalytics::DashboardController, type: :request do
  context "index" do
    before(:all) do
      2.times.each do
        TrackedRequestsByDaySite.create!(
          day: Date.today,
          url_hostname: "foo",
        )
        TrackedRequestsByDayPage.create!(
          day: Date.today,
          url_hostname: "foo",
          url_path: "bar",
        )
      end
    end

    it "renders" do
      get rails_local_analytics.root_path
      expect(response.status).to eq(200)
    end

    it "renders with type param" do
      get rails_local_analytics.root_path, params: {type: "Site"}
      expect(response.status).to eq(200)

      get rails_local_analytics.root_path, params: {type: "Page"}
      expect(response.status).to eq(200)
    end

    it "renders with start_date param" do
      get rails_local_analytics.root_path, params: {type: "Site", start_date: 3.days.ago.to_date}
      expect(response.status).to eq(200)

      get rails_local_analytics.root_path, params: {type: "Page", start_date: 3.days.ago.to_date}
      expect(response.status).to eq(200)
    end

    it "renders with end_date param" do
      get rails_local_analytics.root_path, params: {type: "Site", end_date: 3.days.ago.to_date}
      expect(response.status).to eq(200)

      get rails_local_analytics.root_path, params: {type: "Page", end_date: 3.days.ago.to_date}
      expect(response.status).to eq(200)
    end

    it "renders with search param" do
      get rails_local_analytics.root_path, params: {type: "Site", search: "foo"}
      expect(response.status).to eq(200)

      get rails_local_analytics.root_path, params: {type: "Site", search: "foo bar"}
      expect(response.status).to eq(200)

      get rails_local_analytics.root_path, params: {type: "Page", search: "foo"}
      expect(response.status).to eq(200)

      get rails_local_analytics.root_path, params: {type: "Page", search: "foo bar"}
      expect(response.status).to eq(200)
    end

    it "renders with group_by param" do
      get rails_local_analytics.root_path, params: {type: "Site", group_by: "All"}
      expect(response.status).to eq(200)
      get rails_local_analytics.root_path, params: {type: "Site", group_by: "platform"}
      expect(response.status).to eq(200)

      get rails_local_analytics.root_path, params: {type: "Page", group_by: "All"}
      expect(response.status).to eq(200)
      get rails_local_analytics.root_path, params: {type: "Page", group_by: "referrer_path"}
      expect(response.status).to eq(200)
    end
  end
end
