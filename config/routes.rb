RailsLocalAnalytics::Engine.routes.draw do
  get "/:site", to: "sites#show", as: :site

  get "/:site/referrers", to: "referrers#index", as: :referrers
  get "/:site/referrers/*referrer", to: "referrers#show", as: :referrer

  get "/:site/pages", to: "pages#index", as: :pages
  get "/:site/*page", to: "pages#show", as: :page

  root to: "sites#index", as: :rails_local_analytics
end
