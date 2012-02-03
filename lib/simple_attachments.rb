require 'simple_attachments/attachment_model'
require 'simple_attachments/container_model'
require 'simple_attachments/attachment_controller'
require 'simple_attachments/form_builder_helpers'

module SimpleAttachments
  def self.init
    ActiveRecord::Base.extend AttachmentModel
    ActiveRecord::Base.extend ContainerModel
    ActionController::Base.extend AttachmentsController
    __DIR__ = File.expand_path(File.dirname(__FILE__))
    I18n.load_path += Dir[File.join(__DIR__, 'locales', '*.yml')]
    Rails.application.class.config.assets.paths << File.join(__DIR__, 'assets')
  end
end

SimpleAttachments.init
