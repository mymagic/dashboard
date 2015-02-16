module BootstrapHelper
  def nav_link(name = nil, options = nil, html_options = {}, &block)
    html_options.merge!(class: :active) if current_page?(options)
    link_to name, options, html_options, &block
  end
end
