module MembersHelper
  def member_role(member)
    role = member.regular_member? ? 'member' : member.role
    content_tag(
      'span',
      role.humanize,
      class: "member-role #{ role }",
      title: role.to_s.humanize,)
  end

  def member_avatar_link(member)
    link_to(
      image_tag(member.avatar.url(:icon), class: 'img-rounded'),
      community_member_path(current_community, member)
    )
  end

  def member_filter_description(filter)
    {
      everyone: "Members, mentors and staff.",
      members: "All regular members.",
      mentors: "All mentors.",
      staff: "Staff and administrators."
    }[filter]
  end
end
