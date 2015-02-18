module BootstrapHelper
  def title(title)
    content_for(:title, " - #{ title }")
  end

  def nav_link(name = nil, options = nil, html_options = {}, &block)
    content_tag 'li', class: current_page?(options) ? 'active' : false do
      link_to name, options, html_options, &block
    end
  end

  def page_header(name)
    content_for :page_header do
      content_tag 'div', class: 'page-header' do
        content_tag 'h1', name
      end
    end
  end

  def panel(heading = nil, style: 'default', columns: 4)
    content_tag 'div', class: "col-sm-#{ columns }" do
      content_tag 'div', class: "panel panel-#{ style }" do
        safe_join(
          [
            heading ? content_tag('div', heading, class: 'panel-heading') : nil,
            content_tag('div', class: 'panel-body') do
              yield
            end
          ]
        )
      end
    end
  end
end
