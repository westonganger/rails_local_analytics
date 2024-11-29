class TrackedRequestsByDayPage < RailsLocalAnalytics::ApplicationRecord
  self.table_name = "tracked_requests_by_day_page"

  before_create do
    self.total ||= 1
  end

end
