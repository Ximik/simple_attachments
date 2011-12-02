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
