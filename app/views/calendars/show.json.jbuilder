json.array! [@availabilities + (@events || [])].flatten do |group|
  json.type group.class.to_s

  if group.is_a? Availability
    json.availabilities_ids group.availabilities_ids
    json.title case group.member_ids.size
    when 1
      truncate "#{group.first_names.first} #{group.last_names.first}", length: 20
    when 2..3
      ''
    else
      "and #{group.member_ids.size - 3} more"
    end

    json.start group.date
    json.avatars do
      json.array!(
        group.avatars.each_with_index.map do |avatar, index|
          member = Member.find(group.member_ids[index])
          member.avatar.url(:icon)
        end
      )
    end
  elsif group.is_a? Event
    json.id group.id
    json.title group.title
    json.start group.starts_at
    json.css_style group.external ? 'external-event' : 'community-event'
  end
end
