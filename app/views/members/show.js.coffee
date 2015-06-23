$("#member__content").
  html("<%= escape_javascript(render partial: @partial) %>");
