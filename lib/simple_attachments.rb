module SimpleContainer
  def has_many_attachments(attachments_symbol)
    has_many attachments_symbol, :dependent => :destroy
    attachment_model = attachments_symbol.to_s.classify.constantize
    @@attachment_add = attachments_symbol.to_s.concat('<<')
    send(:define_method, attachments_symbol.to_s.concat('=')) do |attachment_ids|
      attachment_ids.each_value do |attachment_id|
        attachment = attachment.find_by_id attachment_id
        send(@@attachments_add, attachment) unless attachment.nil?
      end
    end
  end
end
ActiveRecord::Base.extend SimpleContainer

module SimpleAttachment
  def attached_to(container_symbol, options={})
    belongs_to container_symbol
    before_save :save_file
    after_destroy :destroy_file
    options.each_pair do |key, value|
      case key
      when :mimetype
        validate :is_mimetype_allowed?
        @@allowed_types = value
        send(:define_method, 'is_mimetype_allowed?') do
          errors.add_to_base t(:mimetype_isnt_allowed) % mimetype unless @@allowed_types.include? mimetype or mimetype.nil?
        end
      when :maxsize
        validate :is_size_ok?
        @@max_filesize = value
        send(:define_method, 'is_size_ok?') do
          errors.add_to_base t(:filesize_is_too_big) % @filesize if @fizesize > @@max_filesize or @filesize.nil?
        end
      end
    end
    send :include, AttachmentMethods
  end

  module AttachmentMethods
    def file=(file)
      if file.nil?
        errors.add_to_base t(:file_loading_error)
        @filesize = nil
      else
        @file = file
        self.filepath = file_path
        self.mimetype = @file.content_type
        @filesize = @file.tempfile.size
      end
    end
    def file_path
      Rails.root.join('uploads', Time.now.to_f.to_s.concat('.').concat(File.basename(@file.filename))).to_s
    end
    def save_file
      File.open(filepath) do |file|
        file.write @file.read
      end
    end
    def destroy_file
      File.delete filepath
    end
  end
end
ActiveRecord::Base.extend SimpleAttachment

module SimpleAttachmentController
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
ApplicationController.extend SimpleAttachmentController
