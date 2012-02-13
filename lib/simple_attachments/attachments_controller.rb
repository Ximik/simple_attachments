module SimpleAttachments::AttachmentsController
  def attachment_controller_for(attachments_symbol, options={})
    skip_before_filter :verify_authenticity_token
    before_filter :load_attachment, :except => :create
    self.class.send(:attr_accessor, :attachment_model)
    self.class.send(:attr_accessor, :ajax)
    self.class.send(:attr_accessor, :sendfile)
    self.attachment_model = attachments_symbol.to_s.classify.constantize
    if options[:ajax].nil?
      self.ajax = options[:ajax]
    else
      self.ajax = true
    end
    self.sendfile = options[:sendfile]
    send :include, ::SimpleAttachments::AttachmentsControllerMethods
  end
end

module SimpleAttachments::AttachmentsControllerMethods

  def create
    @attachment = self.class.attachment_model.new
    if params[:container_id] != 'null' and self.class.ajax
      begin
        container = params[:container_type].classify.constantize.find params[:container_id]
        container.add_attachment @attachment
      rescue
        render_answer(false, [I18n.t('simple_attachments.uploading_error')]) and return
      end
    end
    save_attachment
  end

  def show
    options = []
    options[:type] = @attachment.mimetype
    options[:filename] = @attachment.filename
    options[self.class.sendfile] = true unless self.class.sendfile.nil?
    send_file @attachment.full_file_path, options
  end

  def update
    @attachment.destroy_file
    save_attachment
  end

  def destroy
    @attachment.destroy unless @attachment.nil?
    render :nothing => true
  end

  private

  def load_attachment
    @attachment = self.class.attachment_model.find_by_id params[:id]
    raise ActionController::RoutingError.new('Not Found') if @attachment.nil?
  end

  def save_attachment
    @attachment.file = params[:file]
    @attachment.save
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

  def render_answer(succeed, data)
    render :text => {'succeed' => succeed, 'data' => data}.to_json
  end

end

ActionController::Base.extend SimpleAttachments::AttachmentsController
