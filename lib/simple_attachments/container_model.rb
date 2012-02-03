module SimpleAttachments::ContainerModel
  def has_many_attachments(attachments_symbol)
    has_many attachments_symbol, :dependent => :destroy
    class << self
      attr_accessor :attachments
      attr_accessor :attachment_model
    end
    self.attachments = attachments_symbol.to_s
    self.attachment_model = attachments_symbol.to_s.classify.constantize
    send(:define_method, attachments_symbol.to_s.concat('=')) do |attachment_ids|
      attachment_ids.each do |attachment_id|
        attachment = self.class.attachment_model.find_by_id attachment_id
        send(self.class.attachments).push(attachment) unless attachment.nil?
      end
    end
  end
end
