$ ->
  setupTagsInput = ->
    $('input[data-role=tags]').each ->
      self = $(@)
      if self.data('typeahead-prefetch')
        tags = new Bloodhound
          datumTokenizer: Bloodhound.tokenizers.whitespace
          queryTokenizer: Bloodhound.tokenizers.whitespace
          local: self.data('typeahead-prefetch')
        tags.initialize()
        self.tagsinput
          typeaheadjs:
            source: tags.ttAdapter()
      else
        self.tagsinput()

  activateTimeago = ->
    $('time').each ->
      self = $(@)
      self.timeago().data('active','yes') if self.data('active') isnt 'yes'
    setTimeout(activateTimeago, 60000)

  watchNavRemote = ->
    $('ul.nav-remote li').click ->
      self = $(@)
      self.removeClass('active').siblings().removeClass('active')
      self.addClass('active')

      if document._supports_history_api
        history.replaceState(null, null, self.children('a').attr('href'))

  $(document).on 'ujs', ->
    watchNavRemote()
    activateTimeago()
    setupTagsInput()
