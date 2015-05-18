json.array! @office_hours do |office_hour|
  json.title office_hour.mentor.full_name
  json.start office_hour.time
  json.avatar office_hour.mentor.avatar.icon.url
end
