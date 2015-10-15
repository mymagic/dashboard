enablePopovers = ->
  $('[data-toggle="popover"]').popover()

enableTooltips = ->
  $('.has-member-tooltip').tooltip(
    trigger: 'manual'
    html: true
    animation: false).on('mouseenter', ->
    _this = this
    $(this).tooltip 'show'
    $('.popover').on 'mouseleave', ->
      $(_this).tooltip 'hide'
  ).on 'mouseleave', ->
    _this = this
    setTimeout (->
      if !$('.tooltip:hover').length
        $(_this).tooltip 'hide'
    ), 200

ready = ->
  enablePopovers()
  enableTooltips()

$(document).ready(ready)
$(document).on('page:load', ready)
