json.array! @office_hours do |office_hour|
  json.title office_hour.member.full_name
  json.start office_hour.time
  json.avatars do
    json.array! [office_hour.member.avatar.icon.url]
  end
end
