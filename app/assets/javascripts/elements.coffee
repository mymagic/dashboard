$ ->
  setupTagsInput = ->
    $('input[data-role=tags]').each ->
      self = $(@)
      if self.data('typeahead-url')
        tags = new Bloodhound
          datumTokenizer: Bloodhound.tokenizers.whitespace
          queryTokenizer: Bloodhound.tokenizers.whitespace
          remote:
            url: self.data('typeahead-url') + '?q=%QUERY'
            wildcard: '%QUERY'
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

  $(document).on 'ujs', ->
    setupTagsInput()
    activateTimeago()
