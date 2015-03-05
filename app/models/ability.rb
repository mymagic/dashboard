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

  def create_companies_positions(member)
    cannot :create, CompaniesMembersPosition
    can :create, CompaniesMembersPosition, member_id: member.id
  end

  def initialize(member)
    member ||= Member.new # guest user (not logged in)

    # everyone
    cannot :administrate, :application
    cannot :manage, :all
    can :read, :all

    case member.role
    when 'administrator'
      can :administrate, :application
      can :manage, Position
      can :read, Member
      create_companies_positions(member)
      book_and_cancel_office_hours(member)
    when 'staff'
      can :read, Member
      create_companies_positions(member)
      book_and_cancel_office_hours(member)
    when 'mentor'
      can :read, Member
      can :create, OfficeHour, mentor_id: member.id
    else # a regular Member
      can :read, Member
      create_companies_positions(member)
      book_and_cancel_office_hours(member)
    end

  end
end
