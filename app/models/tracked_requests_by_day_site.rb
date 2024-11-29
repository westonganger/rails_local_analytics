class TrackedRequestsByDaySite < RailsLocalAnalytics::ApplicationRecord
  self.table_name = "tracked_requests_by_day_site"

  before_create do
    self.total ||= 1
  end
end
