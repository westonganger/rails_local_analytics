class TrackedRequestsByDayPage < ApplicationRecord
  self.table_name = "tracked_requests_by_day_page"

  before_create do
    self.total ||= 1
  end

  scope :between_dates, -> (from, to) { where("date BETWEEN ? AND ?", from, to) }
  scope :after, -> (date) { where("date > ?", date) }
  scope :order_by_totals, -> { order(Arel.sql("SUM(total) DESC")) }
  scope :order_by_date, -> { order(:date) }
  scope :top, -> (n = 10) { order_by_totals.limit(n) }

  def self.group_by_url_hostname
    group(:url_hostname).pluck("url_hostname, SUM(total)").map do |row|
      {host: row[0], total: row[1]}
    end
  end

  def self.group_by_url_path
    group(:url_hostname, :url_path).pluck("url_hostname, url_path, SUM(total)").map do |row|
      {host: row[0], path: row[1], total: row[2]}
    end
  end

  def self.group_by_referrer_url_hostname
    group(:referrer_hostname).pluck("referrer_hostname, SUM(total)").map do |row|
      {host: row[0], total: row[1]}
    end
  end

  def self.group_by_referrer_url_path
    group(:referrer_hostname, :referrer_path).pluck("referrer_hostname, referrer_path, SUM(total)").map do |row|
      {host: row[0], path: row[1], total: row[2]}
    end
  end

  def self.group_by_date
    group(:date).select("date, sum(total) AS total")
  end
end
