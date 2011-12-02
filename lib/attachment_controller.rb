module AttachmentController
  def attachment_controller_for(attachment_symbol, options={})
    @attachment_model = attachments_symbol.to_s.classify.constantize
    @@options = options
    send :include, ControllerMethods
  end
  module ControllerMethods
    def create
      @attachment = @attachment_model.new
      @attachment.file = params[:file]
      @attachment.save
      render :json => @attachment.errors.full_messages
    end
    def show
      @attachment = @attachment_model.find_by_id params[:id]
      if @attachment.nil?
      else
        options = @@options
        options[:type] = @attachment.mimetype
        send_file @attachment.filepath, options
      end
    end
    def destroy
      @attachment = @attachment_model.find_by_id params[:id]
      @attachment.destroy unless @attachment.nil?
      render :nothing => true
    end
  end
end


