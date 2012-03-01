module ActionView # :nodoc:
  module Helpers::SimpleAttachments

    # Create +div+ with attachments.
    #
    # Allowed +options+
    # 
    # [:can_destroy]     Show destroy link.
    # [:can_create]      Show add button.
    # [:readonly]        Just sets both :can_destroy and :can_create. True by default.
    # [:destroy_remote]  Destroy the attachment on the server after clicking the destroy link.
    # [:auto_associate]  Associate uploaded file with container at once. Also sets :destroy_remote if havn't set. True by default.

    def self.helper(type, template, object, object_name, method, text, options)
      options[:readonly] = false if options[:readonly].nil?
      options[:can_destroy] ||= options[:readonly]
      options[:can_create] ||= options[:readonly]
      options.delete :readonly
      options[:auto_associate] ||= true if options[:auto_associate].nil?
      container_id = (options[:auto_associate] ? object.id : nil)
      options[:destroy_remote] ||= options[:auto_associate]
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

      def singleton_file(method, text='', options={})
        helper(:singleton, object, method, text, options)
      end

      def multiple_files(method, text='', options={})
        helper(:multiple, object, method, text, options)
      end

      private

      def helper(type, method, text, options) # :nodoc:
        Helpers::SimpleAttachments.helper(type, template, object, object_name, method, text, options)
      end

    end

    module TagHelper

      def singleton_file_tag(object, method, text='', options={})
        helper(:singleton, object, method, text, options)
      end

      def multiple_files_tag(object, method, text='', options={})
        helper(:multiple, object, method, text, options)
      end

      private

      def helper(type, object, method, text, options) # :nodoc:
        Helpers::SimpleAttachments.helper(type, self, object, object.class.to_s.underscore, method, text, options)
      end

    end

  end

  class Helpers::FormBuilder # :nodoc:
    include Helpers::SimpleAttachments::FormHelper
  end
  class Base # :nodoc:
    include Helpers::SimpleAttachments::TagHelper
  end
end
