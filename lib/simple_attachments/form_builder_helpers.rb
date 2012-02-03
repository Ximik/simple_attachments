class ActionView::Helpers::FormBuilder
  def multiple_file_field(method, options={})
    if options[:text].nil?
      text = ''
    else
      text = options[:text]
      options.delete :text
    end
    @template.content_tag(:div,
                          @template.content_tag(:div, text, :class => 'simple_attachments_add_file_div'),
                          :class => 'simple_attachments_main_div',
                          :id => 'simple_attachments_main_div_'.concat(@object_name).concat('_').concat(method.to_s),
                          :data => {:container => @object_name,
                                    :container_id => @object.id,
                                    :attachments => method,
                                    :new_attachment => @template.send(method.to_s.concat('_path')),
                                    :attached => @object.send(@object.class.attachments).map{|a| a.serializable_hash}.to_json,
                                    :other => options.to_json
                          }
    )
  end
end