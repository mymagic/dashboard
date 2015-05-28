
  $(document)
    .on 'click', '.calendar .fc-event-container', ->
      self = $(@)

      if self.data('popover-is-shown')
        self.popover 'hide'
        self.data('popover-is-shown', false)
        return

      index = self.index()
      communityId = $('body').data('community-slug')
      date = self.closest('table')
                 .find("thead td:nth-child(#{index + 1})")
                 .data('date')

      $.ajax
        url: Routes.community_office_hours_path(communityId)
        data: { date: date }
        success: (data) ->
          self.popover
            title: "Office hours on #{moment(date).format("MMM DD, YYYY")}"
            placement: 'top'
            html: true
            container: 'body'
            content: if !!data.trim() then data else 'There are no office hours for this day.'
            trigger: 'manual'
          self.popover 'show'
          self.data('popover-is-shown', true)
