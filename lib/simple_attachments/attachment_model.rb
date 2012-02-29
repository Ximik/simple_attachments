module SimpleAttachments::AttachmentModel

  module Helpers
    def attached_to(name, options = {})
      reflection = belongs_to name, options
      self.class.send(:attr_accessor, :container_name)
      self.container_name = reflection.name
      self.container_name.freeze
      before_save :save_file
      after_destroy :destroy_file
      send :extend, ClassMethods
      send :include, InstanceMethods
    end
  end

  module ClassMethods

    def validates_mimetype(types, options = {})
      options[:message] ||= I18n.t('simple_attachments.mimetype_isnt_allowed')
      validates :mimetype, :inclusion => { :in => types, :message => options[:message] }
    end

    def validates_filesize(options)
      options[:message] ||= I18n.t('simple_attachments.file_is_too_large')
      validates :filesize, :numericality => options
    end

  end

  module InstanceMethods

    def file=(file)
      if file.nil?
        uploading_error
      else
        @file = file
        self.mimetype = @file.content_type
        self.filesize = @file.tempfile.size
        self.filename = File.basename(@file.original_filename) #old browsers hack
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
      File.open(full_file_path, 'w') { |file| file.write @file.read } unless @file.nil?
    rescue
      uploading_error
    end

    def destroy_file
      File.delete full_file_path
    rescue
    end

    def serializable_hash
      data = super
      data['filepath'] = Rails.application.routes.url_helpers.send(self.class.to_s.underscore.concat('_path'), id)
      data
    end
    
    def attached?
      not send(self.class.container_name).nil?
    end

    def uploading_error
      errors[:base] << I18n.t('simple_attachments.uploading_error')
    end

  end

end

ActiveRecord::Base.extend SimpleAttachments::AttachmentModel::Helpers
