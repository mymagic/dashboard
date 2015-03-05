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

  def can_invite(*member_types)
    member_types.map do |member_type|
      can "invite_#{ member_type }".to_sym, :members
    end
  end

  def create_companies_positions(member)
    cannot :create, CompaniesMembersPosition
    can :create, CompaniesMembersPosition, member_id: member.id
  end

  def initialize(member)
    member ||= Member.new # guest user (not logged in)

    # everyone
    cannot :manage, :all
    cannot :read, :all
    cannot :administrate, :application

    case member.role
    when 'administrator'
      can :administrate, :application

      can :administrate, Member

      can :manage, Position

      can :manage, Company

      can :manage, OfficeHour

      can :read, Member
      can :create, Member
      can :update, Member, role: ['administrator', 'staff', 'mentor', '']
      can :destroy, Member, role: ['administrator', 'staff', 'mentor', '']
      can :resend_invitation, Member

      can_invite :administrator, :staff, :mentor, :regular_member

      create_companies_positions(member)
      book_and_cancel_office_hours(member)
    when 'staff'
      can :administrate, :application
      can :administrate, [Member]

      can :read, Company

      can :read, OfficeHour

      can :read, Member
      can :create, Member
      can :update, Member, role: ['mentor', '']
      can :destroy, Member, role: ['mentor', '']
      can :resend_invitation, Member

      can_invite :mentor, :regular_member

      create_companies_positions(member)
      book_and_cancel_office_hours(member)
    when 'mentor'
      can :read, Member

      can :read, Company

      can :read, OfficeHour

      can :create, OfficeHour, mentor_id: member.id
    else # a regular Member
      can :read, Member

      can :read, Company

      can :read, OfficeHour

      create_companies_positions(member)
      book_and_cancel_office_hours(member)
    end
  end
end
