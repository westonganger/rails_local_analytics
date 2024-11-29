module RailsLocalAnalytics
  class ReferrersController < ApplicationController
    before_action :require_date_range

    def index
      @referrers = current_tracked_requests_by_day.top(100).group_by_referrer_url_hostname
      @histogram = Histogram.new(current_tracked_requests_by_day.order_by_date.group_by_date, from_date, to_date)
      @previous_histogram = Histogram.new(previous_tracked_requests_by_day.order_by_date.group_by_date, previous_from_date, previous_to_date)
    end

    def show
      referrer_hostname, referrer_path = params[:referrer].split("/", 2)
      scope = current_tracked_requests_by_day.where(referrer_hostname: referrer_hostname)
      scope = scope.where(referrer_path: "/" + referrer_path) if referrer_path.present?
      previous_scope = previous_tracked_requests_by_day.where(referrer_hostname: params[:referrer])
      @histogram = Histogram.new(scope.order_by_date.group_by_date, from_date, to_date)
      @previous_histogram = Histogram.new(previous_scope.order_by_date.group_by_date, previous_from_date, previous_to_date)
      @previous_pages = scope.top(100).group_by_referrer_url_path
      @next_pages = scope.top(100).group_by_url_path
    end
  end
end
