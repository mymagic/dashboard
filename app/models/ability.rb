class Ability
  include CanCan::Ability

  def initialize(member)
    member ||= Member.new # guest user (not logged in)

    if member.new_record?
      can :read, :all
      can :create, Member
    else
      can :read, :all
    end
  end
end
