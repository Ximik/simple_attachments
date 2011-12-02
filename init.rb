require 'attachment_model'
ActiveRecord::Base.extend AttachmentModel
require 'container_model'
ActiveRecord::Base.extend ContainerModel
require 'attachment_controller'
ApplicationController.extend AttachmentController
require 'form_builder_helpers'
ActionView::Helpers::FormBuilder.extend FormBuilderHelpers
