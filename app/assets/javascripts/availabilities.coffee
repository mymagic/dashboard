$ ->
  $(document)
    .on 'change', '#availability_slot_duration', ->
      updateEndTimeByDuration()

    .on 'change', '#availability_start_time_5i', ->
      startMinutes = parseInt $('#availability_start_time_5i').val()
      dulation = parseInt $('#availability_slot_duration').val()
      availableMinutes = (mins for mins in [15, 30, 45, 60] when (mins % (startMinutes + dulation)) is 0)

      $('#availability_end_time_5i option').each ->
        self = $(@)
        value = parseInt(self.val())
        value = 60 if value is 0

        if (value is availableMinutes) or (value in availableMinutes)
          self.removeClass('hide')
        else
          self.addClass('hide')

      updateEndTimeByDuration()

  updateEndTimeByDuration = ->
    slotDuration = $('#availability_slot_duration').val()
    startTimeHours = $('#availability_start_time_4i').val()
    startTimeMins = $('#availability_start_time_5i').val()

    endTime = moment(hours: startTimeHours, minutes: startTimeMins)
      .add(moment.duration(parseInt(slotDuration), 'minutes'))

    $('#availability_end_time_4i').val(endTime.format('HH'))
    $('#availability_end_time_5i').val(endTime.format('mm'))
