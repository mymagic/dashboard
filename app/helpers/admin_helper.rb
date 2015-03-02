module AdminHelper
  def member_icon(member)
    return unless member.role
    tag('span',
        class: "member-icon #{ member.role }",
        title: member.role.to_s.humanize)
  end
end
