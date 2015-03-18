module MembersHelper
  def member_role(member)
    return unless member.role
    content_tag('span',
        member.role.humanize,
        class: "member-role #{ member.role }",
        title: member.role.to_s.humanize,)
  end
end
