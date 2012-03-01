module SimpleAttachments::AttachmentsController

  module Helpers

    # Mark controller as controller for attachment resource.
    #
    # Just put at any place of your controller.
    #
    #   attachment_controller
    #
    # Sometimes you have to specify your resource manually.
    #
    #   attachment_controller :resource => MyNamespace::Attachment

    def attachment_controller(options = {})
      before_filter :load_attachment, :except => :create
      self.class.send(:attr_accessor, :attachment_model)
      self.attachment_model = (options[:resource] or controller_path.classify.constantize)
      send :include, InstanceMethods
    end
  end

  module InstanceMethods

    def create # :nodoc:
      @attachment = self.class.attachment_model.new
      @attachment.file = params[:file]
      if @attachment.save and params[:container_id] != 'null'
        begin
          container = params[:container_model].classify.constantize.find params[:container_id]
          associate(container, params[:method])
          container.save
        rescue
          @attachment.uploading_error
        end
      end
      if @attachment.errors.any?
        succeed = false
        data = @attachment.errors.messages.values.flatten
        @attachment.destroy
      else
        succeed = true
        data = @attachment.serializable_hash
      end
      render_answer(succeed, data)
    end

    def show # :nodoc:
      send_file @attachment.full_file_path, :type => @attachment.mimetype, :filename => @attachment.filename
    end

    def destroy # :nodoc:
      @attachment.destroy
      render :nothing => true
    end

    private

    # Before filter to load attachment resource.
    #
    # If you use another way to load it then just skip this filter.
    #
    #   skip_before_filter :load_attachment

    def load_attachment
      @attachment = self.class.attachment_model.find params[:id]
    rescue
      raise ActionController::RoutingError.new('Not Found')
    end

    # Associate attachment with container.
    # Works only if you use +:auto_associate+ option (switched on by default).
    #
    # Redefine it if you want to have some extra control. E.g. CanCan authorization.
    #
    #   def associate(container, method)
    #     authorize! :update, container
    #     super
    #   end

    def associate(container, method)
      container.add_attachment method, self.class.attachment_model, self.id
    end

    # Renders answer for javascript

    def render_answer(succeed, data)
      render :text => {'succeed' => succeed, 'data' => data}.to_json
    end

  end

end

ActionController::Base.extend SimpleAttachments::AttachmentsController::Helpers
