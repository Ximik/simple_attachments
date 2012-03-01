require File.expand_path('../boot', __FILE__)

require 'rails/all'

module App
  class Application < Rails::Application
    config.encoding = 'utf-8'
  end
end
