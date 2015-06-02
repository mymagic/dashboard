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

  setCalendars = ->
    $('.calendar').each ->
      self = $(@)

      self.fullCalendar
        events: self.data('url')
        eventRender: (event, element) ->
          $(element).find('.fc-time').remove() if self.data('ignore-time')

          if event.avatars
            avatars = for avatar in event.avatars[0..2]
              $('<img />', src: avatar, class: 'img-circle')

            $(element).find('.fc-content').prepend avatars

  $(document).on 'ujs', ->
    setupTagsInput()
    activateTimeago()
    setCalendars()
