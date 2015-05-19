json.array! @office_hours_group do |group|
  json.title case group.member_ids.size
  when 1
    "#{group.first_names.first} #{group.last_names.first}"
  when 2..3
    ''
  else
    "and #{group.member_ids.size - 3} more"
  end

  json.start group.time
  json.avatars do
    json.array!(
      group.avatars.each_with_index.map do |avatar, index|
        if avatar.present?
          "/uploads/member/avatar/#{group.member_ids[index]}/icon_#{avatar}"
        else
          '/images/missing/member/icon_default.png'
        end
      end
    )
  end
end
