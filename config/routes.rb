RailsLocalAnalytics::Engine.routes.draw do
  get "/tracked_requests", to: "dashboard#index"

  root to: "dashboard#index"
end
