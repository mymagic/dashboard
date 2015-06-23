$("#paginated_collection__content").
  replaceWith("<%= escape_javascript(
    render(partial: 'shared/paginated_collection',
               locals: { objects: @companies, class_name: 'Company' })
  ) %>");
