Rails.application.configure do
  if Rails::VERSION::STRING.to_f >= 7.1
    config.action_dispatch.show_exceptions = :rescuable
  else
    config.action_dispatch.show_exceptions = true
  end
end
