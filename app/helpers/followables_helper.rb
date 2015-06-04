module FollowablesHelper
  def followable_link(followable)
    if followable.is_a? Member
      member_link followable
    else
      discussion_link followable
    end
  end
end
