module SimpleAttachments::ContainerModel
  def has_many(name, options = {}, &extension)
    if options[:with] == :simple_attachments
      self.class.send(:attr_accessor, :attachments)
      self.class.send(:attr_accessor, :attachment_model)
      self.attachments = name.to_s
      self.attachment_model = self.attachments.classify.constantize
      send(:define_method, self.attachments + '=') do |attachment_ids|
        attachment_ids.each do |attachment_id|
          attachment = self.class.attachment_model.find_by_id attachment_id
          send(self.class.attachments).push(attachment) unless attachment.nil?
        end
      end
      add_polymorphic if options[:polymorphic]
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
      send(:define_method, self.attachment + '=') do |attachment_ids|
        attachment = self.class.attachment_model.find_by_id attachment_id
        send(self.class.attachment + '=', attachment) unless attachment.nil?
      end
      add_polymorphic if options[:polymorphic]
      options.delete :with
    end
    super
  end

  private

  def add_polymorphic
    unless self.attachment_model.method_defined? :container_types
      self.attachment_model.class.send(:attr_accessor, :container_types)
      self.attachment_model.class.container_types = []
    end
    self.attachment_model.class.container_types << self.class.to_s.underscore
  end
end

ActiveRecord::Base.extend SimpleAttachments::ContainerModel
