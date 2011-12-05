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
      if @attachment.new_record?
        render :text => '<div>error</div>'.concat @attachment.errors.full_messages.map{|e| "<div>#{e}</div>"}.join
      else
        id = @attachment.id
        render :text => "<div>#{id}</div><div>#{@attachment.filesize}</div><div>#{send(self.class.attachment_url id}</div>"
      end
    end
    def show
      @attachment = self.class.attachment_model.find_by_id(params[:id])
      raise ActionController::RoutingError.new('Not Found') if @attachment.nil?
      options = self.class.options
      options[:type] = @attachment.mimetype
      send_file @attachment.filepath, self.class.options
    end
    def destroy
      @attachment = self.class.attachment_model.find_by_id params[:id]
      @attachment.destroy unless @attachment.nil?
      render :nothing => true
    end
  end
end


