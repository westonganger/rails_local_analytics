module RailsLocalAnalytics
  class DashboardController < ApplicationController

    def index
      params[:type] ||= "Site"

      case params[:type]
      when "Site"
        @klass = TrackedRequestsByDaySite
      when "Page"
        @klass = TrackedRequestsByDayPage
      else
        raise ArgumentError
      end

      if params[:group_by].present? && !@klass.display_columns.include?(params[:group_by])
        params[:group_by] = "All"
      else
        params[:group_by] ||= "All"
      end

      if params[:start_date].present?
        @start_date = Date.parse(params[:start_date])
      else
        @start_date = Date.today
      end

      if params[:end_date]
        @end_date = Date.parse(params[:end_date])
      else
        @end_date = Date.today
      end

      if @end_date < @start_date
        @end_date = @start_date
      end

      @tracked_requests = fetch_records(@start_date, @end_date)

      prev_start_date = @start_date - (@end_date - @start_date)
      prev_end_date = @end_date - (@end_date - @start_date)

      @prev_period_tracked_requests = fetch_records(prev_start_date, prev_end_date)
    end

    private

    def fetch_records(start_date, end_date)
      tracked_requests = @klass
        .where("day >= ?", @start_date)
        .where("day <= ?", @end_date)
        .order(total: :desc)

      if params[:search].present?
        tracked_requests = tracked_requests.multi_search(params[:search])
      end

      return tracked_requests
    end
  end
end
