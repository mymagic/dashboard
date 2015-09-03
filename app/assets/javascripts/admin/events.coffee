$ ->
  document._initializeMap = ->
    geocoder = new google.maps.Geocoder()
    latLng = getLatLng()
    document._map = new google.maps.Map(document.getElementById('map_canvas'),
      zoom: parseInt($('#event_location_zoom').val())
      center: latLng
      mapTypeId: google.maps.MapTypeId.ROADMAP)

    document._marker = new google.maps.Marker
      position: latLng
      title: 'Event Location'
      map: document._map
      draggable: true

    setMarkerPosition(latLng)

    $('#event_location_detail').focusout ->
      if addressSelected()
        address = $('#event_location_detail').val()
        geocoder.geocode
          'address': address,
          'partialmatch': true,
          document._geocodeResult
    google.maps.event.addListener document._map, 'zoom_changed', ->
      setZoomLevel(document._map.getZoom())
    google.maps.event.addListener document._marker, 'dragend', ->
      setMarkerPosition(document._marker.getPosition())

    watchLocationType()

  document._geocodeResult = (results, status) ->
    if (status == 'OK' and results.length > 0)
      document._marker.setPosition results[0].geometry.location
      setMarkerPosition results[0].geometry.location
      document._map.setCenter results[0].geometry.location

  setMarkerPosition = (latLng) ->
    $('#event_location_latitude').val(latLng.lat())
    $('#event_location_longitude').val(latLng.lng())

  setZoomLevel = (level) ->
    $('#event_location_zoom').val(level)

  getLatLng = ->
    new google.maps.LatLng(
      $('#event_location_latitude').val(),
      $('#event_location_longitude').val())

  hideMap = -> $('#map_canvas').hide()
  showMap = -> $('#map_canvas').show()
  addressSelected = ->
    $('#event_location_type').find('option:selected').val() == 'address'

  setLocationDetailLabel = ->
    label = $('#event_location_type').
      find('option:selected').
      data('detail-label')
    $('label[for=event_location_detail]').html(label)

  watchLocationType = ->
    $('#event_location_type').change ->
      setLocationDetailLabel()
      if addressSelected()
        showMap()
        google.maps.event.trigger(document._map, 'resize')
        document._map.setCenter(getLatLng())
      else
        hideMap()

  setupMap = ->
    setLocationDetailLabel()
    hideMap() unless addressSelected()
    script = document.createElement('script')
    script.type = 'text/javascript'
    script.src = 'https://maps.googleapis.com/maps/api/js?v=3.exp' +
        '&signed_in=true&callback=document._initializeMap'
    document.body.appendChild(script)

  setupNetworkCheckboxes = ->
    $('input[name="event[external]"]').on 'change', ->
      $('.network_checkboxes').prop('checked', false)

    $('.network_checkboxes').on 'change', ->
      if $('input[name="event[external]"]:checked').val() == 'false'
        $('.network_checkboxes').prop('checked', false)
        $(this).prop('checked', true)

  init = ->
    setupMap() if ($('#map_canvas').length > 0)
    setupNetworkCheckboxes()

  $(document).on('ujs', init)
