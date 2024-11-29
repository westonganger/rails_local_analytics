module RailsLocalAnalytics
  class SitesController < ApplicationController
    before_action :require_date_range, only: :show

    def index
      @sites =TrackedRequestsByDayPage.after(30.days.ago).order_by_totals.group_by_url_hostname
      redirect_to(site_path(@sites.first.host)) if @sites.size == 1
    end

    def show
      @histogram = Histogram.new(current_tracked_requests_by_day.order_by_date.group_by_date, from_date, to_date)
      @previous_histogram = Histogram.new(previous_tracked_requests_by_day.order_by_date.group_by_date, previous_from_date, previous_to_date)
      @referrers = current_tracked_requests_by_day.top.group_by_referrer_url_hostname
      @pages = current_tracked_requests_by_day.top.group_by_url_path
    end
  end
end
