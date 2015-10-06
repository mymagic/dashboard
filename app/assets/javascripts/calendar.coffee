$ ->

  $(document)
    .on 'ujs', ->
      setCalendars()

    .on 'focus', ':not(.popover, .availability)', ->
      $('.popover').popover('hide')

    .on 'click', '.calendar .fc-event-container.event', ->
      communitySlug = $('body').data('community-slug')
      networkSlug = $('body').data('network-slug')
      window.location.href = Routes.community_network_event_path(communitySlug, networkSlug, $(@).data('id'))

    .on 'mouseleave', '.calendar-popover', ->
      id = $(this).attr('id')
      $eventItem = $("[aria-describedby=#{id}]")

      unless $(event.toElement).is($eventItem)
        $eventItem.popover('hide')
        $eventItem.data('popover-is-shown', false)

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
                 .addClass(event.css_style)
                 .attr('data-id', event.id)

        eventMouseover: (event, jsEvent, view) ->
          $eventItem = $(this)
          unless $eventItem.data('popover-is-shown')
            type = event.type.toLowerCase()
            date = new Date(event._start._i)
            displayEventPopover($eventItem, type, date)

        eventMouseout: (event, jsEvent, view) ->
          $eventItem = $(this)
          $popover = $("##{$eventItem.attr('aria-describedby')}")
          toElement = jsEvent.toElement
          if !$(toElement).is($eventItem) and !$(toElement).has($eventItem).length and
            !isInside($popover, jsEvent)
              $eventItem.popover('hide')
              $eventItem.data('popover-is-shown', false)

  displayEventPopover = ($eventItem, type, date) ->
    memberId = $eventItem.closest('.calendar').data('member-id')
    route = getRoute(type, date)
    eventType = { availability: "Office Hours", event: "Events" }
    $.ajax
      url: route
      data: { member_id: memberId } if memberId
      success: (data) ->
        $eventItem.popover
          title: title(eventType[type], date)
          placement: 'top'
          html: true
          container: 'body'
          content: if !!data.trim() then data else "There are no #{eventType[type].toLowerCase()} for this day."
          trigger: 'manual'
          placement: (context, src) ->
            $(context).addClass('calendar-popover')
            'top'
        $(".popover").hide()
        $eventItem.popover('show')
        $eventItem.data('popover-is-shown', true)

  getRoute = (type, date) ->
    communitySlug = $('body').data('community-slug')
    networkSlug = $('body').data('network-slug')

    if type == "availability"
      Routes.community_network_availability_calendar_path(communitySlug, networkSlug,
        date.getFullYear(), date.getMonth() + 1, date.getDate())
    else
      Routes.community_network_event_calendar_path(communitySlug, networkSlug,
        date.getFullYear(), date.getMonth() + 1, date.getDate())

  title = (type, date) ->
    "<h4>#{type} on #{moment(date).format("MMM DD, YYYY")}</h4> \
    <br/>Time shown in your local time <span>#{$('body').data('time-zone')}</span>"

  isInside = (element, event) ->
    position = element.position()
    return false unless position
    x = event.pageX
    y = event.pageY
    width = element.width()
    height = element.height()
    left = position.left
    top = position.top
    inRangeX = x > left and x < left + width
    inRangeY = y > top and y < top + height + 12
    inRangeX and inRangeY
