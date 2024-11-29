require "rails_local_analytics/version"
require "rails_local_analytics/engine"
require "browser/browser"

module RailsLocalAnalytics

  def self.record_request(request:, attr_overrides: nil)
    if request.is_a?(Hash)
      request_hash = request
    else
      ### Make request object generic so that it can be used outside of the controller

      request_hash = {
        referrer: request.referrer,
        host: request.host,
        path: request.path,
        user_agent: request.user_agent,
        http_accept_language: request.env["HTTP_ACCEPT_LANGUAGE"],
      }
    end

    json_hash = {
      date: Date.today.to_s,
      request_hash: request_hash,
      attr_overrides: attr_overrides,
    }

    if RailsLocalAnalytics.config.background_jobs
      json_str = JSON.generate(json_hash) # convert to json string so that its compatible with all job backends
      RecordRequestJob.perform_later(json_str)
    else
      RecordRequestJob.new.perform(json_hash)
    end

  rescue => e
    if Rails.env.development? || Rails.env.test?
      raise e
    else
      Rails.logger.error(e.inspect)
      Rails.logger.error(e.backtrace.join("\n"))
    end
  end

  def self.config(&block)
    c = Config

    if block_given?
      block.call(c)
    else
      return c
    end
  end

  class Config
    @@background_jobs = true
    mattr_reader :background_jobs

    def self.background_jobs=(val)
      @@background_jobs = !!val
    end
  end

end
