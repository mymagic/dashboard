$ ->

  $(document)
    .on 'ujs', ->
      setCalendars()

    .on 'click', '.calendar .fc-event-container.event', ->
      communitySlug = $('body').data('community-slug')
      window.location.href = Routes.community_event_path(communitySlug, $(@).data('id'))

    .on 'click', '.calendar .fc-event-container.availability', ->
      self = $(@)
      memberId = self.closest('.calendar').data('member-id')

      $('.fc-event-container')
        .not(@)
        .popover 'hide'
        .data('popover-is-shown', false)

      if self.data('popover-is-shown')
        self.popover 'hide'
        self.data('popover-is-shown', false)
        return

      index = self.index()
      communitySlug = $('body').data('community-slug')
      date = moment(self.closest('table')
                        .find("thead td:nth-child(#{index + 1})")
                        .data('date'))

      $.ajax
        url: Routes.community_availability_slots_path(communitySlug, date.year(), date.month() + 1, date.date())
        data: { member_id: memberId } if memberId
        success: (data) ->
          self.popover
            title: "Office hours on #{date.format("MMM DD, YYYY")}"
            placement: 'top'
            html: true
            container: 'body'
            content: if !!data.trim() then data else 'There are no office hours for this day.'
            trigger: 'manual'
          self.popover 'show'
          self.data('popover-is-shown', true)

  setCalendars = ->
    $('.calendar').each ->
      self = $(@)
      memberId = self.data('member-id')

      self.fullCalendar
        eventSources: [
          url: self.data('url')
          data: { member_id: memberId } if memberId
        ]
        eventRender: (event, element) ->
          element = $(element)

          switch event.type
            when 'Availability'
              element.find('.fc-time').remove()

              if event.avatars
                avatars = for avatar in event.avatars[0..2]
                  $('<img />', src: avatar, class: 'img-circle')

                element.find('.fc-content')
                       .prepend(avatars)

        eventAfterRender: (event, element, _view) ->
          element = $(element)
          element.closest('.fc-event-container')
                 .addClass(event.type.toLowerCase())
                 .attr('data-id', event.id)
