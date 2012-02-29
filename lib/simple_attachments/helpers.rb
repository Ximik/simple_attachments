module ActionView
  module Helpers::SimpleAttachments

    def self.helper(type, template, object, object_name, method, options)
      if options[:text].nil?
        text = ''
      else
        text = options[:text]
        options.delete :text
      end
      options[:auto_associate] = true if options[:auto_associate].nil?
      if options[:auto_associate]
        container_id = object.id
        destroy_remote = true
      else
        container_id = nil
        destroy_remote = false
      end
      options.delete :auto_associate
      attached = object.send(method)
      attached = attached.map{|a| a.serializable_hash} if type == :multiple
      attachments_path = template.send object.class.reflections[method].class_name.pluralize.underscore.concat('_path') #FIXME
      template.content_tag(:div,
                           template.content_tag(:div, text, :class => 'simple_attachments_add_file_div'),
                           :class => "simple_attachments_#{type}_div",
                           :id => 'simple_attachments_'.concat(object_name).concat('_').concat(method.to_s),
                           :data => {:container_model => object_name,
                                     :container_id => container_id,
                                     :destroy_remote => destroy_remote,
                                     :method => method,
                                     :attachments_path => attachments_path, 
                                     :attached => attached.to_json,
                                     :other => options.to_json
                                    }
                          )
    end

    module FormHelper
      def multiple_file_field(method, options={})
        Helpers::SimpleAttachments.helper(:multiple, template, object, object_name, method, options)
      end
    end

    module TagHelper
      def file_tag(object, method, options={})
        Helpers::SimpleAttachments.helper(:singleton, self, object, object.class.to_s.underscore, method, options)
      end
    end

  end

  class Helpers::FormBuilder
    include Helpers::SimpleAttachments::FormHelper
  end
  class Base
    include Helpers::SimpleAttachments::TagHelper
  end
end
