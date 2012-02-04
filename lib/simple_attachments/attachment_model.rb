module SimpleAttachments::AttachmentModel
  def belongs_to(name, options = {})
    if options[:with] == :simple_attachments
      before_save :save_file
      after_destroy :destroy_file
      self.class.send(:attr_accessor, :container_name)
      self.class.send(:define_method, :validates_mimetype) do |types|
        validates :mimetype, :inclusion => { :in => types, :message => I18n.t('simple_attachments.mimetype_isnt_allowed') }
      end
      self.class.send(:define_method, :validates_filesize) do |options|
        options[:message] = I18n.t('simple_attachments.file_is_too_large')
        validates :filesize, :numericality => options
      end
      self.container_name = name.to_s
      send :include, ::SimpleAttachments::AttachmentModelMethodes
      options.delete :with
    end
    super
  end
end

module SimpleAttachments::AttachmentModelMethodes
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
    "#{Time.now.to_f}.#{filename}"
  end
  def full_file_path
    Rails.root.join('uploads', filepath).to_s
  end
  def save_file
    begin
      File.open(full_file_path, 'w') { |file| file.write @file.read } unless @file.nil?
    rescue
      errors[:base] << I18n.t('simple_attachments.uploading_error')
    end
  end
  def destroy_file
    begin
      File.delete full_file_path
    rescue
    end
  end
  def serializable_hash
    data = super
    data['filepath'] = Rails.application.routes.url_helpers.send(self.class.to_s.underscore.concat('_path'), id)
    data
  end
  def container
    send self.class.container_name
  end
  def container_id=(id)
    send self.class.container_name + '_id=', id
  end
end

ActiveRecord::Base.extend SimpleAttachments::AttachmentModel
