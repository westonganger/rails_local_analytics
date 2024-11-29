$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "rails_local_analytics/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "rails_local_analytics"
  spec.version     = RailsLocalAnalytics::VERSION
  spec.authors     = ["Weston Ganger"]
  spec.email       = ["weston@westonganger.com"]
  spec.homepage    = "https://github.com/westonganger/rails_local_analytics"
  spec.summary     = "Simple, performant, local analytics for Rails. Solves 95% of your needs until your ready to start taking analytics more seriously using another tool."
  spec.description = spec.summary
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib,public}/**/*", "LICENSE", "Rakefile", "README.md"]

  spec.required_ruby_version = ">= 2.6"

  spec.add_dependency "rails", ">= 6.0"
  spec.add_dependency "browser"

  spec.add_development_dependency "rspec-rails"
  spec.add_development_dependency "database_cleaner"
  spec.add_development_dependency "rails-controller-testing"
end
