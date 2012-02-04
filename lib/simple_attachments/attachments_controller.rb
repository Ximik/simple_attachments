module SimpleAttachments::AttachmentsController
  def attachment_controller_for(attachments_symbol, options={})
    skip_before_filter :verify_authenticity_token
    self.class.send(:attr_accessor, :attachment_model)
    self.class.send(:attr_accessor, :options)
    self.attachment_model = attachments_symbol.to_s.classify.constantize
    self.options = options
    send :include, ::SimpleAttachments::AttachmentsControllerMethods
  end
end

module SimpleAttachments::AttachmentsControllerMethods
  def create
    @attachment = self.class.attachment_model.new
    @attachment.container_id = params[:container_id] unless params[:container_id] == 'null'
    if self.class.attachment_model.method_defined? :container_types
      if self.class.attachment_model.container_types.include? params[:container_type]
        @attachment.container_type = params[:container_type].classify
      else
        raise ::ActiveRecord::ActiveRecordError
      end
    end
    @attachment.file = params[:file]
    save_attachment
  end
  def show
    @attachment = self.class.attachment_model.find_by_id params[:id]
    raise ActionController::RoutingError.new('Not Found') if @attachment.nil?
    options = self.class.options
    options[:type] = @attachment.mimetype
    options[:filename] = @attachment.filename
    send_file @attachment.full_file_path, options
  end
  def update
    @attachment = self.class.attachment_model.find_by_id params[:id]
    raise ActionController::RoutingError.new('Not Found') if @attachment.nil?
    @attachment.destroy_file
    @attachment.file = params[:file]
    save_attachment
  end
  def destroy
    @attachment = self.class.attachment_model.find_by_id params[:id]
    @attachment.destroy unless @attachment.nil?
    render :nothing => true
  end

  private

  def save_attachment
    @attachment.save
    if @attachment.errors.any?
      succeed = false
      data = @attachment.errors.messages.values.flatten
      @attachment.destroy
    else
      succeed = true
      data = @attachment.serializable_hash
    end
    render :text => {'succeed' => succeed, 'data' => data}.to_json
  end
end

ActionController::Base.extend SimpleAttachments::AttachmentsController
