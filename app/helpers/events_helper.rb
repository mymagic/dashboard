module EventsHelper
  RSVP_STATES = {
    attending: 'Join',
    not_attending: 'Decline',
    maybe_attending: 'Maybe'
  }

  def rsvp_event_button(event, state)
    rsvp_link(event, state, RSVP_STATES[state.to_sym], class: 'btn btn-default')
  end

  def rsvp_link(event, state, name = nil, html_options = {})
    link_to(
      name,
      rsvp_community_network_event_path(current_community, current_network, event, rsvp: { state: state }),
      html_options.merge(method: :patch))
  end

  def event_static_map(event)
    query = {
      center: event.location_coordinates,
      size: '230x230',
      zoom: event.location_zoom,
      markers: "color:blue|#{ event.location_coordinates }"
    }
    url = URI.parse("https://maps.googleapis.com/maps/api/staticmap")
    url.query = query.to_query
    image_tag(url, class: 'img-responsive')
  end

  def event_header(event)
    starts_at_in_member_tz = event_start_time(event)
    safe_join([
      event.title,
      tag('br'),
      content_tag('small', starts_at_in_member_tz)], ' ')
  end

  def event_type_label(event, with_event: false)
    wording = []
    wording << (event.external? ? 'External' : 'Network')
    wording << 'Event' if with_event
    style = event.external? ? 'external-event' : 'community-event'
    content_tag('span', wording.join(' '), class: "label #{ style }")
  end

  def event_start_time(event, format = '%A, %B %d, %Y at %l:%M%P')
    event.starts_at.in_time_zone(current_member.time_zone).strftime(format)
  end

  def event_times(event, time_zone)
    template = '%A, %B %d, %Y at %l:%M%P'
    times = {}
    times['Begins'] = event.starts_at.in_time_zone(time_zone).strftime(template)
    times['Ends'] = event.ends_at.in_time_zone(time_zone).strftime(template)
    times['Timezone'] = time_zone
    times
  end

  def event_link(event)
    link_to event.title, [current_community, current_network, event]
  end
end
