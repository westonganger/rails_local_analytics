Rails.application.routes.draw do
  mount RailsLocalAnalytics::Engine, at: "/"
end
