$ ->
  watchMemberSidebarNavigation = ->
    $('#member__sidebar > ul.nav li').click ->
      self = $(@)
      self.removeClass('active').siblings().removeClass('active')
      self.addClass('active')

  $(document).on 'ujs', ->
    watchMemberSidebarNavigation()
