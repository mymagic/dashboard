module ApplicationHelper
  def favicon_path
    return current_community.logo.url(:icon) if current_community
    image_path('missing/community/icon_default.png')
  end

  def markdown(text)
    options = {
      filter_html:     true
    }

    extensions = {
      autolink:           true,
      superscript:        true
    }

    renderer = Redcarpet::Render::HTML.new(options)
    markdown = Redcarpet::Markdown.new(renderer, extensions)

    markdown.render(text).html_safe
  end
end
