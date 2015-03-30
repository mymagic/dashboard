class ImagePreviewInput < SimpleForm::Inputs::FileInput
  def input(wrapper_options)
    version = input_html_options.delete(:preview_version)
    out = ActiveSupport::SafeBuffer.new
    out << template.image_tag(
            object.
              send(attribute_name).
              tap { |o| break o.send(version) if version }.
              send('url')
           )
    out << template.button_tag(
             'Upload image',
             class: 'btn btn-default browse-image-preview',
             type: 'button'
           )
    out << @builder.input(attribute_name, wrapper_html: { class: 'hide' })
    out << @builder.input("#{attribute_name}_cache", as: :hidden)
  end
end
