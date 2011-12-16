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
          return if mimetype.nil?
          errors[:base] << I18n.t('simple_attachments.mimetype_isnt_allowed') unless self.class.allowed_types.include? mimetype
        end
      when :maxsize
        validate :is_size_ok?
        class << self
          attr_accessor :maxsize
        end
        self.maxsize = value
        send(:define_method, 'is_size_ok?') do
          return if filesize.nil?
          errors[:base] << I18n.t('simple_attachments.file_is_too_large') if filesize > self.class.maxsize
        end
      end
    end
    send :include, SimpleAttachmentsAttachmentMethods
  end

  module SimpleAttachmentsAttachmentMethods
    def file=(file)
      if file.nil?
        errors[:base] << I18n.t('simple_attachments.uploading_error')
      else
        @file = file
        self.mimetype = @file.content_type
        self.filesize = @file.tempfile.size
        self.filename = File.basename(@file.original_filename) #IE hack
        self.filepath = file_path
      end
    end
    def file_path
      Rails.root.join('uploads', Time.now.to_f.to_s.concat('.').concat(filename)).to_s
    end
    def save_file
      File.open(filepath, 'w') do |file|
        file.write @file.read
      end
    end
    def destroy_file
      File.delete filepath
    end
    def serializable_hash
      data = super
      data['filepath'] = Rails.application.routes.url_helpers.send self.class.to_s.underscore.concat('_path'), id
      data
    end
  end
end
