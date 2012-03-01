module SimpleAttachments::ContainerModel

  module Helpers

    # Mark model as container and creates association.
    #
    # Syntax is identical to +has_many+.
    #
    #   has_many_attachments :attachments

    def has_many_attachments(name, options = {})
      reflection = has_many name, options
      send(:define_method, reflection.plural_name + '_=') do |attachment_ids|
        method, model = recover_vars(__method__)
        old_attachment_ids = send method.singularize.concat('_ids')
        attachment_ids = attachment_ids.map { |id| id.to_i }
        model.destroy_all :id => (old_attachment_ids - attachment_ids)
        (attachment_ids - old_attachment_ids).each do |attachment_id|
          add_attachment(method, model, attachment_id)
        end
      end
      send :include, InstanceMethods
    end

    # Mark model as container and creates association.
    #
    # Syntax is identical to +has_one+.
    #
    #   has_one_attachment :attachment

    def has_one_attachment(name, options = {})
      reflection = has_one name, options
      send(:define_method, reflection.name.to_s + '_=') do |attachment_id|
        method, model = recover_vars(__method__)
        add_attachment(method, model, attachment_id)
      end
      send :include, InstanceMethods
    end

  end

  module InstanceMethods

    def add_attachment(method, model, attachment_id) # :nodoc:
      attachment = model.find_by_id attachment_id
      return if attachment.nil?
      return if attachment.attached?
      if reflections[method.to_sym].instance_variable_get :@collection
        send(method) << attachment
      else
        old_attachment = send(method)
        old_attachment.destroy unless old_attachment.nil?
        send (method + '='), attachment
      end
    end

    private

    def recover_vars(method) # :nodoc:
      method = method.to_s.chomp('_=')
      model = reflections[method.to_sym].klass
      [method, model]
    end

  end

end

ActiveRecord::Base.extend SimpleAttachments::ContainerModel::Helpers
