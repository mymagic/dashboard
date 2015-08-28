module MembersHelper
  def member_filter_description
    {
      everyone: "Members, mentors and staff.",
      members: "All regular members.",
      mentors: "All mentors.",
      staff: "Staff and administrators."
    }[@filter]
  end

  def member_role(member)
    role = member.regular_member? ? 'member' : member.role
    content_tag(
      'span',
      role.humanize,
      class: "member__role member_role--#{ role }",
      title: role.to_s.humanize,)
  end

  def member_link(member)
    safe_join([member_avatar_link(member), member_name_link(member)], ' ')
  end

  def member_avatar_link(member)
    link_to(
      image_tag(member.avatar.url(:icon), class: 'img-rounded'),
      [member.community, (current_network || member.default_network), member]
    )
  end

  def member_name_link(member)
    link_to(
      member.full_name,
      [member.community, (current_network || member.default_network), member])
  end

  def member_positions(member, with_spacing: false)
    comp_pos = member.positions_in_companies.map do |company, positions|
      "#{ company.name } (#{ positions.to_sentence })"
    end
    with_spacing ? safe_join(comp_pos, tag('br')) : comp_pos.to_sentence
  end
end
