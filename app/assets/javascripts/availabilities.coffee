$ ->
  $(document)
    .on 'change', '#availability_slot_duration', ->
      slot_duration = $(@).val()
      start_time_hours = $('#availability_start_time_4i').val()
      start_time_mins = $('#availability_start_time_5i').val()

      end_time = moment(hours: start_time_hours, minutes: start_time_mins)
        .add(moment.duration(parseInt(slot_duration), 'minutes'))

      $('#availability_end_time_4i').val(end_time.format('HH'))
      $('#availability_end_time_5i').val(end_time.format('mm'))
