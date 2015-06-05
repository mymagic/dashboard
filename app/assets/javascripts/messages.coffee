$ ->
  scrollPanel = ->
    $('.messages-panel__conversations').each (_, panel)->
      panel.scrollTop = panel.scrollHeight

  $(document).on 'ujs', ->
    scrollPanel()
