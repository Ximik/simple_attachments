App::Application.configure do
  config.encoding = 'utf-8'
  config.cache_classes = true
  config.whiny_nils = true
  config.action_controller.perform_caching = false
  config.action_dispatch.show_exceptions = false
  config.action_controller.allow_forgery_protection = true
  config.active_support.deprecation = :stderr
  config.assets.enabled = true
  config.assets.version = '1.0'
end
