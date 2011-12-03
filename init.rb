require 'attachment_model'
ActiveRecord::Base.extend AttachmentModel
require 'container_model'
ActiveRecord::Base.extend ContainerModel
require 'attachment_controller'
ActionController::Base.extend SimpleAttachmentsController
require 'form_builder_helpers'
