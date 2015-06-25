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
#= require calendar
#= require messages
#= require admin/positions
#= require admin/events


# Turn off loading spinner
NProgress.configure(showSpinner: false)

# Turbolinks TransitionCache
Turbolinks.enableTransitionCache();

$ ->
  document._supports_history_api = !!(window.history && history.pushState)
  $(document)
    .on 'ready', -> $(@).trigger('ujs')
    .on 'ajaxStop', -> $(@).trigger('ujs')
    .on 'page:load', -> $(@).trigger('ujs')
    .on 'page:fetch', -> NProgress.start()
    .on 'page:change', -> NProgress.done()
    .on 'page:restore', -> NProgress.remove()
