module SimpleAttachments
  class Engine < ::Rails::Engine
  end
end
I18n.load_path << File.join(File.dirname(__FILE__), '..', 'locales', 'en.yml')

require 'simple_attachments/attachment_model'
require 'simple_attachments/container_model'
require 'simple_attachments/attachments_controller'
require 'simple_attachments/helpers'
