
  $(document)
    .on 'click', '.calendar .fc-event-container', ->
      self = $(@)

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
