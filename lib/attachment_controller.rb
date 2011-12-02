module AttachmentController
  def attachment_controller_for(attachment_symbol, options={})
    @attachment_model = attachments_symbol.to_s.classify.constantize
    @@options = options
    send :include, SimpleAttachmentsControllerMethods
  end
  module SimpleAttachmentsControllerMethods
    def create
      @attachment = @attachment_model.new
      @attachment.file = params[:file]
      @attachment.save
      render :json => @attachment.errors.full_messages
    end
    def show
      @attachment = @attachment_model.find_by_id(params[:id]) || raise ActionController::RoutingError.new('Not Found')
      options = @@options
      options[:type] = @attachment.mimetype
      send_file @attachment.filepath, options
    end
    def destroy
      @attachment = @attachment_model.find_by_id params[:id]
      @attachment.destroy unless @attachment.nil?
      render :nothing => true
    end
  end
end


