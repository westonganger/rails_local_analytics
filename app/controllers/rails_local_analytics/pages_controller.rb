module RailsLocalAnalytics
  class PagesController < ApplicationController
    before_action :require_date_range

    def index
      @histogram = Histogram.new(current_tracked_requests_by_day.order_by_date.group_by_date, from_date, to_date)
      @previous_histogram = Histogram.new(previous_tracked_requests_by_day.order_by_date.group_by_date, previous_from_date, previous_to_date)
      @pages = current_tracked_requests_by_day.top(100).group_by_url_path
    end

    def show
      page_scope = current_tracked_requests_by_day.where(page: page_from_params)
      previous_page_scope = previous_tracked_requests_by_day.where(page: page_from_params)
      @histogram = Histogram.new(page_scope.order_by_date.group_by_date, from_date, to_date)
      @previous_histogram = Histogram.new(previous_page_scope.order_by_date.group_by_date, previous_from_date, previous_to_date)
      @next_pages = current_tracked_requests_by_day.where(referrer_hostname: params[:site], referrer_path: page_from_params).top(100).group_by_url_path
      @previous_pages = page_scope.top(100).group_by_referrer_page
    end
  end
end
