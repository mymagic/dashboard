#= require jquery
#= require bootstrap-sprockets
#= require jquery_ujs
#= require turbolinks

#= require jquery-sortable

#= require admin/positions

#= require bootstrap-setup

#= require_tree .

$ ->
  $(document)
    # Trigger ujs after page load
    .on 'page:load', ->
      $(@).trigger('ujs')

    # Trigger ujs after ajax success
    .on 'ajax:success', ->
      $(@).trigger('ujs')

    .trigger('page:change')
    .trigger('page:load')
