$("#filter_navigation").
  replaceWith("<%= escape_javascript(
    render(partial: 'filters',
               layout:  'layouts/filter_navigation',
               locals: { current_filter: @filter, tag: @tag, filters: Discussion::FILTERS })
  ) %>");

$("#paginated_collection__content").
  replaceWith("<%= escape_javascript(
    render(partial: 'shared/paginated_collection',
               locals: { objects: @discussions, class_name: 'Discussion' })
  ) %>");
