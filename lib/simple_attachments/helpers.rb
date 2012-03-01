module ActionView
  module Helpers::SimpleAttachments

    def self.helper(type, template, object, object_name, method, text, options)
      options[:readonly] = false if options[:readonly].nil?
      if options[:readonly]
        options[:can_destroy] ||= false
        options[:can_create] ||= false
      else
        options[:can_destroy] ||= true
        options[:can_create] ||= true
      end
      options.delete :readonly
      options[:auto_associate] ||= true if options[:auto_associate].nil?
      if options[:auto_associate]
        container_id = object.id
        options[:destroy_remote] ||= true
      else
        container_id = nil
        options[:destroy_remote] ||= false
      end
      options.delete :auto_associate
      attached = object.send(method)
      if attached.is_a? Array
        attached = attached.map{|a| a.serializable_hash}
      else
        attached = attached.serializable_hash unless attached.nil?
      end
      attachments_path = template.send object.class.reflections[method].class_name.pluralize.underscore.concat('_path') #FIXME
      template.content_tag(:div,
                           template.content_tag(:div, text, :class => 'simple_attachments_add_file_div'),
                           :class => "simple_attachments_div simple_attachments_#{type}_div",
                           :data => {:container_model => object_name,
                                     :container_id => container_id,
                                     :method => method,
                                     :attachments_path => attachments_path, 
                                     :attached => attached.to_json,
                                     :options => options.to_json
                                    }
                          )
    end

    module FormHelper
      def multiple_file_field(method, text='', options={})
        Helpers::SimpleAttachments.helper(:multiple, template, object, object_name, method, text, options)
      end
    end

    module TagHelper
      def file_tag(object, method, text='', options={})
        Helpers::SimpleAttachments.helper(:singleton, self, object, object.class.to_s.underscore, method, text, options)
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
