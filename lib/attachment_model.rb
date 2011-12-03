module AttachmentModel
  def attached_to(container_symbol, options={})
    belongs_to container_symbol
    before_save :save_file
    after_destroy :destroy_file
    options.each_pair do |key, value|
      case key
      when :mimetype
        validate :is_mimetype_allowed?
        class << self
          attr_accessor :allowed_types
        end
        self.allowed_types = value
        send(:define_method, 'is_mimetype_allowed?') do
          errors[:base] << I18n.t('simple_attachments.mimetype_isnt_allowed') unless self.class.allowed_types.include? mimetype or mimetype.nil?
        end
      when :maxsize
        validate :is_size_ok?
        class << self
          attr_accessor :max_filesize
        end
        self.max_filesize = value
        send(:define_method, 'is_size_ok?') do
          errors[:base] << I18n.t('simple_attachments.file_is_too_large') if @fizesize > self.class.max_filesize or @filesize.nil?
        end
      end
    end
    send :include, SimpleAttachmentsAttachmentMethods
  end

  module SimpleAttachmentsAttachmentMethods
    def file=(file)
      if file.nil?
        errors[:base] << I18n.t('simple_attachments.uploading_error')
        @filesize = nil
      else
        @file = file
        self.filepath = file_path
        self.mimetype = @file.content_type
        @filesize = @file.tempfile.size
      end
    end
    def file_path
      Rails.root.join('uploads', Time.now.to_f.to_s.concat('.').concat(File.basename(@file.original_filename))).to_s
    end
    def save_file
      File.open(filepath, 'w') do |file|
        file.write @file.read
      end
    end
    def destroy_file
      File.delete filepath
    end
  end
end
