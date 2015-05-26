#= require jquery
#= require bootstrap-sprockets
#= require jquery_ujs
#= require turbolinks
#= require jquery-sortable
#= require jquery.timeago
#= require js-routes
#= require moment
#= require bootstrap-tagsinput
#= require fullcalendar
#= require nprogress
#= require nprogress-turbolinks
#= require typeahead.bundle

#= require bootstrap-setup
#= require elements
#= require calendar
#= require admin/positions


# Turn off loading spinner
NProgress.configure(showSpinner: false)

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
