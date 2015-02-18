class Ability
  include CanCan::Ability

  def book_and_cancel_office_hours(member)
    can :book, OfficeHour
    cannot :book, OfficeHour, mentor_id: member.id

    cannot :cancel, OfficeHour
    can :cancel, OfficeHour, participant_id: member.id

    cannot :destroy, OfficeHour
    can :destroy, OfficeHour, mentor_id: member.id
  end

  def initialize(member)
    member ||= Member.new # guest user (not logged in)

    # everyone
    cannot :administrate, :application

    if member.new_record?
      can :create, Member
    else
      can :read, :all

      book_and_cancel_office_hours(member)
    end

    if member.administrator?
      can :manage, :all
      can :administrate, :application

      book_and_cancel_office_hours(member)
    end
  end
end
