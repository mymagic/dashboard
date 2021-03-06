module BootstrapHelper
  def title(title)
    content_for(:title, " - #{ title }")
  end

  def nav_link(name = nil, options = nil, html_options = {}, &block)
    page_options = block_given? ? name : options
    content_tag 'li', class: current_page?(page_options) ? 'active' : nil do
      link_to name, options, html_options, &block
    end
  end

  def page_header(name)
    h = []
    h << content_tag('div', yield, class: 'page-header-action') if block_given?
    h << content_tag('h1', name)
    content_for :page_header do
      content_tag 'div', h.join("\n").html_safe, class: 'page-header'
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

  def definition_list(list, horizontal: true)
    content_tag 'dl', class: (horizontal ? 'dl-horizontal' : false) do
      safe_join(
        list.map do |term, definition|
          [content_tag('dt', term), content_tag('dd', definition)]
        end.flatten
      )
    end
  end

  def network_filter_dropdown(resource:, html_class: nil)
    safe_join([
      content_tag('button',
                  class: "btn btn-default dropdown-toggle #{html_class}",
                  id: 'network_filter_dropdown',
                  'data-toggle' => 'dropdown') do
        safe_join([
          current_network.try(:name) || 'All Networks',
          content_tag(:span, '', class: 'caret')
        ], ' ')
      end,
      content_tag('ul',
                  class: 'dropdown-menu',
                  'alria-labelledby' => 'network_filter_dropdown') do
        safe_join([
          content_tag('li', link_to('All Networks', [current_community, :admin, resource.constantize])),
          *current_community.networks.map do |network|
            content_tag 'li', link_to(network.name, [current_community, network, :admin, resource.constantize])
          end
        ])
      end
    ])
  end

end
