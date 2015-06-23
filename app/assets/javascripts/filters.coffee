$ ->
  watchFilterNavigation = ->
    $('#filter_navigation > ul.nav li').click ->
      self = $(@)
      self.removeClass('active').siblings().removeClass('active')
      self.addClass('active')

  $(document).on 'ujs', ->
    watchFilterNavigation()
