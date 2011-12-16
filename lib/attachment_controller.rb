module SimpleAttachmentsController
  def attachment_controller_for(attachments_symbol, options={})
    skip_before_filter :verify_authenticity_token
    class << self
      attr_accessor :attachment_model
      attr_accessor :attachment_helper
      attr_accessor :options
    end
    self.attachment_model = attachments_symbol.to_s.classify.constantize
    self.attachment_helper = attachments_symbol.to_s.singularize.concat('_path')
    self.options = options
    send :include, SimpleAttachmentsControllerMethods
  end
  module SimpleAttachmentsControllerMethods
    def create
      @attachment = self.class.attachment_model.new
      @attachment.file = params[:file]
      @attachment.save
      if @attachment.errors.any?
        succeed = false
        data = @attachment.errors.full_messages
      else
        succeed = true
        data = @attachment.serializable_hash
        data['filepath'] = send self.class.attachment_helper, @attachment.id
      end
      render :text => {"succeed" => succeed, "data" => data}.to_json
    end
    def show
      @attachment = self.class.attachment_model.find_by_id params[:id]
      raise ActionController::RoutingError.new('Not Found') if @attachment.nil?
      options = self.class.options
      options[:type] = @attachment.mimetype
      options[:filename] = @attachment.filename
      send_file @attachment.filepath, options
    end
    def destroy
      @attachment = self.class.attachment_model.find_by_id params[:id]
      @attachment.destroy unless @attachment.nil?
      render :nothing => true
    end
  end
end


