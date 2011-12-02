require 'attachment_model'
ActiveRecord::Base.extend AttachmentModule
require 'container_model'
ActiveRecord::Base.extend ContainerModule
require 'attachment_controller'
ApplicationController.extend AttachmentController
require 'form_builder_helpers'
ActionView::Helpers::FormBuilder.extend FormBuilderHelpers
