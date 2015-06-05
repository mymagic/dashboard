class Ability
  include CanCan::Ability

  def can_invite(*member_types)
    member_types.map do |member_type|
      can "invite_#{ member_type }".to_sym, :members
    end
  end

  def create_companies_positions(member)
    cannot :create, CompaniesMembersPosition
    can :have, CompaniesMembersPosition
    can :create, CompaniesMembersPosition, member_id: member.id
  end

  def manage_social_media_links(member)
    can :manage, SocialMediaLink, attachable_type: 'Member', attachable_id: member.id
  end

  def read_messages(member)
    can :read, Message do |message|
      message.sender_id == member.id || message.receiver_id == member.id
    end
  end

  def reserve_slots(member)
    can :create, Slot do |slot|
      slot.availability.member_id != member.id
    end
  end

  def manage_slots(member)
    can [:create, :update, :destroy], Slot do |slot|
      slot.member_id == member.id || slot.availability.member_id == member.id
    end
  end

  def initialize(member)
    member ||= Member.new # guest user (not logged in)

    # everyone
    cannot :manage, :all
    cannot :read, :all
    cannot :administrate, :application
    cannot :invite_employee, Company
    cannot :manage_company, Company
    cannot :invite_company_member, Company
    cannot :have, CompaniesMembersPosition

    can :read, Community

    case member.role
    when 'administrator'
      can :administrate, :application

      can :manage, Community, id: member.community_id

      can :manage, :calendar

      can :manage, Position

      can :manage, Availability
      can [:read, :update, :destroy], Slot
      reserve_slots(member)

      can :manage, SocialMediaLink

      can :manage, Company
      can :manage_company, Company
      can :invite_company_member, Company
      can :manage_members_positions, Company

      create_companies_positions(member)
      can [:manage, :administrate], CompaniesMembersPosition

      can :administrate, Member
      can [:create, :read], Member
      can_invite :administrator, :staff, :mentor, :regular_member
      can :resend_invitation, Member
      can :update, Member, role: ['administrator', 'staff', 'mentor', '', nil]
      can :destroy, Member, role: ['administrator', 'staff', 'mentor', '', nil]
      can [:follow, :unfollow], Member do |other_member|
        other_member.id != member.id
      end

      can [:create, :search], Message
      read_messages(member)

      can :manage, Discussion, community_id: member.community_id
      cannot :unfollow, Discussion, author_id: member.id
      can :manage, Comment do |comment|
        comment.discussion.community_id == member.community_id
      end

      can [:manage, :administrate], Event
      cannot :rsvp, Event do |event|
        event.ended?
      end
    when 'staff'
      can :administrate, :application
      can :administrate, [Member, Company, CompaniesMembersPosition]

      can [:create, :read, :update], Company
      cannot :destroy, Company
      can :manage_company, Company
      can :invite_company_member, Company
      can :manage_members_positions, Company

      create_companies_positions(member)
      can :manage, CompaniesMembersPosition

      can :read, :calendar

      can [:create, :read], Member
      can_invite :mentor, :regular_member
      can :resend_invitation, Member
      can :update, Member, role: ['mentor', '', nil]
      can :destroy, Member, role: ['mentor', '', nil]
      can [:follow, :unfollow], Member do |other_member|
        other_member.id != member.id
      end

      can [:read, :create], Availability
      can :manage, Availability, member_id: member.id

      can :read, Slot
      manage_slots(member)
      reserve_slots(member)

      manage_social_media_links(member)

      can [:create, :search], Message
      read_messages(member)

      can [:create, :read, :follow, :unfollow, :tags], Discussion, community_id: member.community_id
      cannot :unfollow, Discussion, author_id: member.id
      can :create, Comment do |comment|
        comment.discussion.community_id == member.community_id
      end

      can [:manage, :administrate], Event
      cannot :rsvp, Event do |event|
        event.ended?
      end
    when 'mentor'
      can :read, Member
      can [:follow, :unfollow], Member do |other_member|
        other_member.id != member.id
      end

      can :read, Company

      can :read, :calendar

      can [:read, :create], Availability
      can :manage, Availability, member_id: member.id

      can :read, Slot
      manage_slots(member)
      reserve_slots(member)

      manage_social_media_links(member)

      can [:create, :search], Message
      read_messages(member)

      can [:create, :read, :follow, :unfollow, :tags], Discussion, community_id: member.community_id
      cannot :unfollow, Discussion, author_id: member.id
      can :create, Comment do |comment|
        comment.discussion.community_id == member.community_id
      end

      can :read, Event
      can :rsvp, Event do |event|
        !event.ended?
      end
    else # a regular Member
      can :read, :calendar

      can :read, Company
      can [:manage_company, :invite_company_member, :manage_members_positions, :update], Company do |company|
        member.manageable_companies.include?(company)
      end
      create_companies_positions(member)

      can [:approve, :reject, :update], CompaniesMembersPosition do |cmp|
        member.manageable_companies.include? cmp.company
      end

      can [:destroy], CompaniesMembersPosition do |cmp|
        member.manageable_companies.include?(cmp.company) &&
          !cmp.members_last_manager_position_in_company?(member)
      end

      can :read, Member
      can :create, Member do |new_member|
        new_member.companies_positions.map(&:company).uniq.any? &&
          (new_member.companies_positions.map(&:company).uniq -
            member.manageable_companies).empty?
      end
      can [:follow, :unfollow], Member do |other_member|
        other_member.id != member.id
      end

      can [:read, :create], Availability
      can :manage, Availability, member_id: member.id

      can :read, Slot
      manage_slots(member)
      reserve_slots(member)

      manage_social_media_links(member)

      can [:create, :search], Message
      read_messages(member)

      can [:create, :read, :follow, :unfollow, :tags], Discussion, community_id: member.community_id
      cannot :unfollow, Discussion, author_id: member.id
      can :create, Comment do |comment|
        comment.discussion.community_id == member.community_id
      end
      can :read, Event
      can :rsvp, Event do |event|
        !event.ended?
      end
    end
  end
end
