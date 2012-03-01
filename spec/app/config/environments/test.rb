App::Application.configure do
  # Disable request forgery protection in test environment
  config.action_controller.allow_forgery_protection = false

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Print deprecation notices to the stderr
  config.active_support.deprecation = :stderr
end
