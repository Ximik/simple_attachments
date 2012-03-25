module SimpleAttachments::AttachmentModel

  module Helpers

    # Mark model as attachment and create association.
    #
    # Syntax is identical to +belongs_to+.
    #
    #   attached_to :post
    #
    # Do not use more than one time in one model.
    # However you can use polymorphic associations.
    #
    #   attached_to :container, :polymorphic => true

    def attached_to(name, options = {})
      reflection = belongs_to name, options
      self.class.send(:attr_accessor, :container_name)
      self.container_name = reflection.name
      before_save :save_file
      after_destroy :destroy_file
      send :extend, ClassMethods
      send :include, InstanceMethods
    end

  end

  module ClassMethods

    # Validate mimetype of uploaded file.
    #
    #   validates_mimetype %w(image/png image/gif image/jpeg), :message => 'should be an image'
    #
    # :message is optional.

    def validates_mimetype(types, options = {})
      options[:message] ||= I18n.t('simple_attachments.mimetype_isnt_allowed')
      validates :mimetype, :inclusion => { :in => types, :message => options[:message] }
    end

    # Validate filesize. Syntax is identical to numericality validator. Filesize is given in bytes.
    #
    #   validates_filesize :less_than_or_equal_to => 12e6, :message => 'file is too large'
    #
    # :message is optional.

    def validates_filesize(options)
      options[:message] ||= I18n.t('simple_attachments.file_is_too_large')
      validates :filesize, :numericality => options
    end

  end

  module InstanceMethods

    # Set file for attachment.
    # +file+ is +UploadedFile+ object

    def file=(file)
      if file.nil?
        uploading_error
      else
        @file = file
        self.mimetype = @file.content_type
        self.filesize = @file.tempfile.size
        self.filename = File.basename(@file.original_filename) # old browsers hack
        self.filepath = file_path
      end
    end

    # Generate path to file.
    # Redefine this method if you want another naming logic.

    def file_path
      "#{Time.now.to_f}.#{filename}"
    end

    # Generate full path to file.
    # Redefine this method if you have another place to hold files.

    def full_file_path
      Rails.root.join('uploads', filepath).to_s
    end

    # Save file in the filesystem.

    def save_file
      File.open(full_file_path, 'wb') { |file| file.write @file.read } unless @file.nil?
    rescue
      uploading_error
    end

    # Delete file from the filesystem.

    def destroy_file
      File.delete full_file_path
    rescue
    end

    def serializable_hash # :nodoc:
      data = super
      data['filepath'] = path # changing filepath to file url
      data
    end

    # Test if attached to any container.

    def attached?
      not send(self.class.container_name).nil?
    end

    # Generate error connected to any server problems.

    def uploading_error
      errors[:base] << I18n.t('simple_attachments.uploading_error')
    end

    # Get url to the attachment.

    def path
      Rails.application.routes.url_helpers.send(self.class.to_s.underscore.concat('_path'), id)
    end

  end

end

ActiveRecord::Base.extend SimpleAttachments::AttachmentModel::Helpers
