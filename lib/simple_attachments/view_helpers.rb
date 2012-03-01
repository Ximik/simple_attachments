module SimpleAttachments
  module ViewHelpers

    # Create +div+ with attachments.
    #
    # Allowed +options+
    #
    # [:text]            Text in the add button.
    # [:id]              Main div id.
    # [:can_destroy]     Show destroy link.
    # [:can_create]      Show add button.
    # [:readonly]        Just sets both :can_destroy and :can_create (with not). True by default.
    # [:destroy_remote]  Destroy the attachment on the server after clicking the destroy link.
    # [:auto_associate]  Associate uploaded file with container at once. Also sets :destroy_remote if havn't set. True by default.

    def self.helper(type, template, object, object_name, method, options)
      text = options.delete :text
      id = options.delete :id
      options[:readonly] = false if options[:readonly].nil?
      options[:can_destroy] ||= !options[:readonly]
      options[:can_create] ||= !options[:readonly]
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
                            :id => id,
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

      def singleton_file(method, options={})
        helper(:singleton, method, options)
      end

      def multiple_files(method, options={})
        helper(:multiple, method, options)
      end

      private

      def helper(type, method, options) # :nodoc:
        ViewHelpers.helper(type, @template, object, object_name, method, options)
      end

    end

    module TagHelper

      def singleton_file_tag(object, method, options={})
        helper(:singleton, object, method, options)
      end

      def multiple_files_tag(object, method, options={})
        helper(:multiple, object, method, options)
      end

      private

      def helper(type, object, method, options) # :nodoc:
        ViewHelpers.helper(type, self, object, object.class.to_s.underscore, method, options)
      end

    end

  end
end

module ActionView # :nodoc:
  class Helpers::FormBuilder # :nodoc:
    include SimpleAttachments::ViewHelpers::FormHelper
  end
  class Base # :nodoc:
    include SimpleAttachments::ViewHelpers::TagHelper
  end
end
