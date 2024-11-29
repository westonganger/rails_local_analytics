module RailsLocalAnalytics
  module ApplicationHelper
    def format_view_count(number)
      number_with_delimiter(number.to_i)
    end

    def page_to_params(name)
      name == "/" ? "index" : name[1..-1]
    end

    def page_from_params
      if params[:page] == "index"
        "/"
      elsif params[:page].present?
        "/#{params[:page]}"
      end
    end

    def site_icon(host)
      image_tag("https://icons.duckduckgo.com/ip3/#{host}.ico", referrerpolicy: "no-referrer", class: "referer-favicon")
    end
  end
end
