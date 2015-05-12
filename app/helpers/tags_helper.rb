module TagsHelper
  def tagged_with_header(resource, tag:)
    return resource if tag.blank?
    html = [resource]
    html << content_tag('small') do
      ("tagged with " + content_tag('strong', tag.name)).html_safe
    end
    safe_join(html, ' ')
  end

  def tag_element(tag)
    content_tag 'span', class: 'label label-info' do
      tag.name
    end
  end

  def link_to_tag(tag)
    link_to [current_community, tag], class: 'tag' do
      tag_element tag
    end
  end
end
