json.array! @availabilities do |group|
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
        member = Member.new(id: group.member_ids[index])

        if avatar.present?
          '/' + member.avatar.icon.store_path(avatar)
        else
          member.avatar.icon.default_url
        end
      end
    )
  end
end
