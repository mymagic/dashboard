enablePopovers = ->
  $('[data-toggle="popover"]').popover()

ready = ->
  enablePopovers()

$(document).ready(ready)
$(document).on('page:load', ready)
