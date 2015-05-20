module EventsHelper
  def event_static_map(event)
    query = {
      center: event.location_detail,
      size: '300x300',
      zoom: 16,
      markers: "color:blue|#{ event.location_detail }"
    }
    url = URI.parse("https://maps.googleapis.com/maps/api/staticmap")
    url.query = query.to_query
    image_tag(url, class: 'img-responsive')
  end

  def event_header(event)
    starts_at_in_member_tz = event.
                             starts_at.
                             in_time_zone(current_member.time_zone).
                             strftime('%A, %B %d, %Y at %l:%M%P')
    safe_join([
      event.title,
      tag('br'),
      content_tag('small', starts_at_in_member_tz)
    ])
  end

  def event_times(event, time_zone)
    template = '%A, %B %d, %Y at %l:%M%P'
    times = {}
    times['Begins'] = event.starts_at.in_time_zone(time_zone).strftime(template)
    times['Ends'] = event.ends_at.in_time_zone(time_zone).strftime(template)
    times['Timezone'] = time_zone
    times
  end
end
