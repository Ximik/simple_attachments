module SimpleContainer
  def has_many_attachments(name)
    has_many name, :dependent => :destroy
    validates_associated name
    attachment = name.to_s.classify.constantize
    send(:define_method, name.to_s.concat('=')) do |files|
      files.each_value do |file|
        self.attachments.new.set_file file
      end
    end
  end
end

ActiveRecord::Base.extend SimpleContainer

module SimpleAttachment
  def attached_to(name, options={})
    belongs_to name
    before_save :save_file
    before_destroy :destroy_file
    options.each_pair do |key, value|
      case key
      when :mimetype
        validate :is_mimetype_allowed?
        @@allowed_types = value
        send(:define_method, 'is_mimetype_allowed?') do
          errors.add_to_base t(:mimetype_isnt_allowed) % mimetype unless @@allowed_types.include? mimetype
        end
      when :maxsize
        validate :is_size_ok?
        @@max_filesize = value
        send(:define_method, 'is_size_ok?') do
          errors.add_to_base t(:filesize_is_too_big) % @filesize if @fizesize > @@max_filesize
        end
      end
    end
    send :include, AttachmentMethods
  end

  module AttachmentMethods
    def set_file(file)
      if defined? @@counter
        @@counter += 1
      else
        @@counter = 0
      end
      if file.nil?
        errors.add_to_base t(:file_is_empty)
      else
        @file = file
        self.filepath = file_path @file.original_filename
        self.mimetype = @file.content_type
        @filesize = @file.tempfile.size
      end
    end
    def file_path(filename)
      Rails.root.join('uploads', Time.now.to_i.to_s.concat('_').concat(@@counter.to_s).concat('_').concat(File.basename(filename))).to_s
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
