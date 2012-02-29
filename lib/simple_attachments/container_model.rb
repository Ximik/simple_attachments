module SimpleAttachments::ContainerModel

  module Helpers

    def has_many_attachments(name, options = {})
      reflection = has_many name, options
      send(:define_method, reflection.plural_name + '=') do |attachment_ids|
        method = __method__.to_s.chomp('=')
        model = method.classify.constantize
        old_attachment_ids = method.singularize.concat('_ids')
        attachment_ids = attachment_ids.map { |id| id.to_i }
        model.destroy_all :id => (old_attachment_ids - attachment_ids)
        (attachment_ids - old_attachment_ids).each do |attachment_id|
          add_attachment(method, attachment_id)
        end
      end
      send :include, InstanceMethods
    end

    def has_one_attachment(name, options = {})
      reflection = has_one name, options
      send(:define_method, reflection.name.to_s + '=') do |attachment_id|
        method = __method__.to_s.chomp('=')
        model = method.classify.constantize
        add_attachment(method, attachment_id)
      end
      send :include, InstanceMethods
    end

  end

  module InstanceMethods
    def add_attachment(method, attachment_id)
      attachment = model.find_by_id attachment_id
      return if attachment.nil?
      return if attachment.attached?
      smth = send(method)
      if reflections[method].collection
        smth << attachment
      else
        smth.destroy unless smth.nil?
        smth = attachment
      end
    end
  end

end

ActiveRecord::Base.extend SimpleAttachments::ContainerModel::Helpers
