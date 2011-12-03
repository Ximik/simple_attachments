module ContainerModel
  def has_many_attachments(attachments_symbol)
    has_many attachments_symbol, :dependent => :destroy
    attachment_model = attachments_symbol.to_s.classify.constantize
    class << self
      attr_accessor :attachment_add
    end
    self.attachment_add = attachments_symbol.to_s.concat('<<')
    send(:define_method, attachments_symbol.to_s.concat('=')) do |attachment_ids|
      attachment_ids.each_value do |attachment_id|
        attachment = attachment.find_by_id attachment_id
        send(self.class.attachments_add, attachment) unless attachment.nil?
      end
    end
  end
end
