module SimpleAttachments::AttachmentsController

  module Helpers
    def attachment_controller(options = {})
      skip_before_filter :verify_authenticity_token
      before_filter :load_attachment, :except => :create
      self.class.send(:attr_accessor, :attachment_model)
      self.attachment_model = (options[:attachment_model] or controller_path.classify.constantize)
      send :include, InstanceMethods
    end
  end
  
  module InstanceMethods

    def create
      @attachment = self.class.attachment_model.new
      @attachment.file = params[:file]
      if @attachment.save and params[:container_id] != 'null'
        begin
          container = params[:container_model].classify.constantize.find params[:container_id]
          container.add_attachment params[:method], self.class.attachment_model, @attachment.id
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

    def show
      send_file @attachment.full_file_path, :type => @attachment.mimetype, :filename => @attachment.filename
    end

    def destroy
      @attachment.destroy
      render :nothing => true
    end

    private

    def load_attachment
      @attachment = self.class.attachment_model.find params[:id]
    rescue
      raise ActionController::RoutingError.new('Not Found')
    end

    def render_answer(succeed, data)
      render :text => {'succeed' => succeed, 'data' => data}.to_json
    end

  end

end

ActionController::Base.extend SimpleAttachments::AttachmentsController::Helpers
