module FormBuilderHelpers
  def multiple_file_field(method)
    @template.tag('div', :class => 'simple_attachments_add_div')
    @template.file_field(@object_name, method, :class => 'simple_attachments_file_field')
  end
end
