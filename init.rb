require 'attachment_model'
ActiveRecord::Base.extend AttachmentModel
require 'container_model'
ActiveRecord::Base.extend ContainerModel
require 'attachment_controller'
ActionController::Base.extend SimpleAttachmentsController
require 'form_builder_helpers'
I18n.load_path += Dir[Rails.root.join('vendor', 'plugins', 'simple_attachments', 'locales', '*.yml')]
