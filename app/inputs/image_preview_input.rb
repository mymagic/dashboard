class ImagePreviewInput < SimpleForm::Inputs::FileInput
  def input
    out = ActiveSupport::SafeBuffer.new
    out << template.image_tag(object.send(attribute_name).send('url'))
    out << template.button_tag('Browse Logo', class: 'btn btn-default browse-image-preview')
    out << @builder.input(attribute_name, wrapper_html: { class: 'hide' })
    out << @builder.input("#{attribute_name}_cache", as: :hidden)
  end
end
