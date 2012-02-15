class ActionView::Helpers::FormBuilder
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
      delete = true
    else
      container_id = nil
      delete = false
    end
    options.delete :auto_associate
    @template.content_tag(:div,
                          @template.content_tag(:div, text, :class => 'simple_attachments_add_file_div'),
                          :class => 'simple_attachments_multiple_file_field_div',
                          :id => 'simple_attachments_'.concat(@object_name).concat('_').concat(method.to_s),
                          :data => {:container => @object_name,
                                    :container_id => container_id,
                                    :delete => delete
                                    :attachments => method,
                                    :new_path => @template.send(method.to_s.concat('_path')),
                                    :attached => @object.send(@object.class.attachments).map{|a| a.serializable_hash}.to_json,
                                    :other => options.to_json
                          }
    )
  end
end
