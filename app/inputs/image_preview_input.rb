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
    out << @builder.input(attribute_name, label: false)
    out << @builder.input("#{attribute_name}_cache", as: :hidden)
  end
end
