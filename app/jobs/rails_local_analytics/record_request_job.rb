module RailsLocalAnalytics
  class RecordRequestJob < ApplicationJob
    def perform(json)
      if json.is_a?(String)
        JSON.parse(json)
      end

      request_hash = json.fetch("request_hash")

      custom_attributes_by_model = json.fetch("custom_attributes")

      models.each do |model|
        custom_attrs = custom_attributes_by_model && custom_attributes_by_model[model.name]

        attrs = build_attrs(model, custom_attrs, request_hash)

        existing_record = model.find_by(attrs)

        if existing_record
          existing_record.increment!(:total, 1)
        else
          model.create!(attrs)
        end
      end
    end

    private

    def models
      # you can override this method if you want to use custom models
      [TrackedRequestsByDaySite, TrackedRequestsByDayPage]
    end

    def build_attrs(model, attrs, request_hash)
      field = "url_hostname"
      if !skip_field?(field, attrs, model)
        attrs[field] = request_hash.fetch("host").downcase
      end

      field = "url_path"
      if !skip_field?(field, attrs, model)
        attrs[field] = request_hash.fetch("path").downcase
      end

      if request_hash.fetch("referrer").present?
        field = "referrer_hostname"
        if !skip_field?(field,attrs, model)
          referrer_hostname, referrer_path = split_referrer(request_hash.fetch("referrer"))
          attrs[field] = referrer_hostname
        end

        field = "referrer_path"
        if !skip_field?(field, attrs, model)
          if referrer_path.nil?
            referrer_hostname, referrer_path = split_referrer(request_hash.fetch("referrer"))
          end
          attrs[field] = referrer_path
        end
      end

      if request_hash.fetch("user_agent").present?
        field = "platform"
        if !skip_field?(field, attrs, model)
          browser ||= create_browser_object(request_hash)
          attrs[field] = browser.platform.name
        end

        field = "browser_engine"
        if !skip_field?(field, attrs, model)
          browser ||= create_browser_object(request_hash)
          attrs[field] = get_browser_engine(browser)
        end
      end
    end

    def self.split_referrer(referrer)
      referrer = referrer.downcase

      uri = URI(referrer)

      if uri.host.present?
        return [
          uri.host,
          uri.path.presence,
        ]
      else
        strings = referrer.split("/", 2)
        return [
          strings[0],
          (strings[1].present? ? "/#{strings[1]}" : nil),
        ]
      end
    end

    def self.get_browser_engine(browser)
      if browser.webkit?
        # must come before all other checks because Firefox/Chrome on iOS devices is actually using Safari under the hood
        "webkit"
      elsif browser.chromium_based?
        "blink"
      elsif browser.firefox?
        "gecko"
      else
        nil # store nothing, data is not useful
      end
    end

    def self.create_browser_object(request_hash)
      Browser.new(
        request_hash.fetch(:user_agent),
        accept_language: request_hash.fetch(:http_accept_language),
      )
    end

    def self.skip_field?(field, attrs, model)
      attrs&.has_key?(field) || !model.column_names.include?(field)
    end

  end
end
