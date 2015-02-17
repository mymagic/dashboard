class Ability
  include CanCan::Ability

  def initialize(member)
    member ||= Member.new # guest user (not logged in)

    # everyone
    cannot :administrate, :application

    if member.new_record?
      can :create, Member
    else
      can :read, :all
    end

    if member.administrator?
      can :manage, :all
      can :administrate, :application
    end
  end
end
