module MembersHelper
  def member_role(member)
    return unless member.role
    content_tag(
      'span',
      member.role.humanize,
      class: "member-role #{ member.role }",
      title: member.role.to_s.humanize,)
  end

  def member_avatar_link(member)
    link_to(
      image_tag(member.avatar.url(:icon), class: 'img-rounded'),
      community_member_path(current_community, member)
    )
  end
end
