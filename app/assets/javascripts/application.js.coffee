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
#= require nprogress-ajax
#= require typeahead.bundle

#= require bootstrap-setup
#= require elements
#= require availabilities
#= require members
#= require calendar
#= require messages
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

    .on 'page:fetch', -> NProgress.start()
    .on 'page:change', -> NProgress.done()
    .on 'page:restore', -> NProgress.remove()
    .trigger('page:change')
    .trigger('page:load')
