module Rails
  class Engine < ::Rails::Engine
    config.before_configuration do
      assets.paths << File.join(File.join(File.expand_path(File.dirname(__FILE__)), 'assets')
    end
  end
end
