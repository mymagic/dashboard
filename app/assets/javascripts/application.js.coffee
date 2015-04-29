#= require jquery
#= require bootstrap-sprockets
#= require jquery_ujs
#= require turbolinks
#= require jquery-sortable
#= require jquery.timeago
#= require nprogress
#= require nprogress-turbolinks

#= require admin/positions
#= require bootstrap-setup


# Turn off loading spinner
NProgress.configure(showSpinner: false)

activateTimeago = ->
  $('time').each ->
    $this = $(this)
    $this.timeago().data('active','yes') if $this.data('active') != 'yes'
  setTimeout(activateTimeago, 60000)

$ ->
  $(document)
    # Trigger ujs after page load
    .on 'page:load', ->
      $(@).trigger('ujs')
      activateTimeago()

    # Trigger ujs after ajax success
    .on 'ajax:success', ->
      $(@).trigger('ujs')

    .trigger('page:change')
    .trigger('page:load')
