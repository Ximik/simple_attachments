module ActionView::Helpers
  module SimpleAttachmentsFormHelper
    def multiple_file_field(method, options={})
      if options[:text].nil?
        text = ''
      else
        text = options[:text]
        options.delete :text
      end
      options[:auto_associate] = true if options[:auto_associate].nil?
      if options[:auto_associate]
        container_id = @object.id
        destroy_remote = true
      else
        container_id = nil
        destroy_remote = false
      end
      options.delete :auto_associate
      @template.content_tag(:div,
                            @template.content_tag(:div, text, :class => 'simple_attachments_add_file_div'),
                            :class => 'simple_attachments_multiple_file_field_div',
                            :id => 'simple_attachments_'.concat(@object_name).concat('_').concat(method.to_s),
                            :data => {:container_model => @object_name,
                                      :container_id => container_id,
                                      :destroy_remote => destroy_remote,
                                      :attachments => method,
                                      :new_attachment_path => @template.send(method.to_s.concat('_path')),
                                      :attached => @object.send(@object.class.attachments).map{|a| a.serializable_hash}.to_json,
                                      :other => options.to_json
                            }
                           )
    end
  end
  module SimpleAttachmentsTagHelper
    def file_tag(container, attachment, options={})
      content_tag(:div,
                  content_tag(:div, text, :class => 'simple_attachments_add_file_div'),
                  :class => 'simple_attachments_file_tag_div',
                  :id => 'simple_attachments_'.concat(container).concat('_').concat(attachment),
                  :data => {:container_model => container.class.to_s.underscore,
                            :container_id => container.id,
                            :attachment => attachment,
                            :new_attachment_path => @template.send(attachment.concat('_path')),
                            :attached => container.send(container.class.attachment).serializable_hash.to_json,
                            :other => options.to_json
                  )
    end
  end
 
  FormBuilder.extend SimpleAttachmentsFormHelper
  include SimpleAttachmentsTagHelper
end
