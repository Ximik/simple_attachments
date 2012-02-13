module SimpleAttachments::ContainerModel

  def has_many(name, options = {}, &extension)
    if options[:with] == :simple_attachments
      self.class.send(:attr_accessor, :attachments)
      self.class.send(:attr_accessor, :attachment_model)
      self.attachments = name.to_s
      self.attachment_model = self.attachments.classify.constantize
      send(:define_method, :add_attachment) do |attachment|
        send(self.class.attachments) << attachment unless attachment.nil?
      end
      send(:define_method, self.attachments + '=') do |attachment_ids|
        send(self.class.attachments).update_attributes :container_id => nil
        attachment_ids.each do |attachment_id|
          attachment = self.class.attachment_model.find_by_id attachment_id
          add_attachment attachment if attachment.container.nil?
        end
      end
      options.delete :with
    end
    super
  end

  def has_one(name, options = {})
    if options[:with] == :simple_attachments
      self.class.send(:attr_accessor, :attachment)
      self.class.send(:attr_accessor, :attachment_model)
      self.attachment = name.to_s
      self.attachment_model = self.attachment.classify.constantize
      send(:define_method, :add_attachment) do |attachment|
        send(self.class.attachment + '=', attachment) unless attachment.nil?
      end
      send(:define_method, self.attachment + '=') do |attachment_ids|
        attachment = self.class.attachment_model.find_by_id attachment_id
        add_attachment attachment if attachment.container.nil?
      end
      options.delete :with
    end
    super
  end

end

ActiveRecord::Base.extend SimpleAttachments::ContainerModel
