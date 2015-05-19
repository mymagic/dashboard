module EventsHelper
  def event_static_map(event)
    query = { center: event.location_detail, size: '400x400', zoom: 15 }
    url = URI.parse("https://maps.googleapis.com/maps/api/staticmap")
    url.query = query.to_query
    image_tag(url, class: 'img-responsive')
  end

  def event_header(event)
    safe_join([
      event.title,
      tag('br'),
      content_tag('small', event.starts_at_in_zone.strftime('%A, %B %d, %Y at %l:%M%P %Z'))
    ])
  end

  def event_times(event)
    times = {}
    times['Begins'] = event.starts_at_in_zone.strftime('%A, %B %d, %Y at %l:%M%P')
    times['Ends'] = event.ends_at_in_zone.strftime('%A, %B %d, %Y at %l:%M%P')
    times['Timezone'] = event.ends_at_in_zone.strftime('%Z')
    times
  end
end
