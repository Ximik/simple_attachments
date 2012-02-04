module SimpleAttachments::ContainerModel
  def has_many(name, options = {}, &extension)
    if options[:with] == :simple_attachments
      class << self
        attr_accessor :attachments
        attr_accessor :attachment_model
      end
      self.attachments = name.to_s
      self.attachment_model = self.attachments.classify.constantize
      send(:define_method, self.attachments + '=') do |attachment_ids|
        attachment_ids.each do |attachment_id|
          attachment = self.class.attachment_model.find_by_id attachment_id
          send(self.class.attachments).push(attachment) unless attachment.nil?
        end
      end
      options.delete :with
    end
    super
  end
  def has_one(name, options = {})
    if options[:with] == :simple_attachments
      class << self
        attr_accessor :attachment
        attr_accessor :attachment_model
      end
      self.attachment = name.to_s
      self.attachment_model = self.attachment.classify.constantize
      send(:define_method, self.attachment + '=') do |attachment_ids|
        attachment = self.class.attachment_model.find_by_id attachment_id
        send(self.class.attachment + '=', attachment) unless attachment.nil?
      end
      options.delete :with
    end
    super
  end
end

ActiveRecord::Base.extend SimpleAttachments::ContainerModel
