$ ->
  setupTags = ->
    $('input[data-role=tags]').each ->
      self = $(@)
      if self.data('typeahead-url')
        tags = new Bloodhound
          datumTokenizer: Bloodhound.tokenizers.obj.whitespace('name')
          queryTokenizer: Bloodhound.tokenizers.whitespace
          prefetch:
            url: self.data('typeahead-url')
            filter: (list)->
              $.map list, (tag)-> name: tag
        tags.initialize()
        self.tagsinput
          typeaheadjs:
            name: 'tags'
            displayKey: 'name'
            valueKey: 'name'
            source: tags.ttAdapter()
      else
        self.tagsinput()

  activateTimeago = ->
    $('time').each ->
      self = $(@)
      self.timeago().data('active','yes') if self.data('active') isnt 'yes'
    setTimeout(activateTimeago, 60000)

  $(document).on 'ujs', ->
    setupTags()
    activateTimeago()
    $("input[data-role=tagsinput], select[multiple][data-role=tagsinput]").tagsinput()
