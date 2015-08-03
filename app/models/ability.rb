class Ability
  include CanCan::Ability

  def can_invite(*member_types)
    member_types.map do |member_type|
      can "invite_#{ member_type }".to_sym, :members
    end
  end

  def manage_social_media_links(member)
    can(:manage,
        SocialMediaLink,
        attachable_type: 'Member',
        attachable_id: member.id)
  end

  def create_messages(member)
    can :create, Message
    can :send_message_to, Member do |receiver|
      receiver.id != member.id
    end
    can :read_messages_with, Member do |receiver|
      receiver != member
    end
  end

  def read_messages(member)
    can :read, Message do |message|
      message.sender_id == member.id || message.receiver_id == member.id
    end
  end

  def reserve_slots(member)
    can [:create, :reserve], Slot do |slot|
      slot.availability.member_id != member.id
    end
  end

  def manage_slots(member)
    can [:update, :destroy], Slot do |slot|
      slot.member_id == member.id || slot.availability.member_id == member.id
    end
  end

  def initialize(member)
    member ||= Member.new # guest user (not logged in)

    # everyone
    cannot [:manage, :read], :all
    cannot :administrate, :application
    cannot :invite_employee, Company
    cannot :manage_company, Company
    cannot :invite_company_member, Company

    can :read, [Activity, Community]
    can :read, [:calendar, Company, Member, Availability, Slot, Event]

    manage_slots(member)
    reserve_slots(member)

    can :search, Message
    create_messages(member)
    read_messages(member)

    cannot :unfollow, Discussion, author_id: member.id

    can :rsvp, Event
    cannot :rsvp, Event do |event|
      event.ended?
    end

    can [:follow, :unfollow], Member do |other_member|
      other_member.id != member.id
    end

    manage_social_media_links(member)

    can :manage, Availability, member_id: member.id

    can :create, Comment do |comment|
      comment.discussion.network.community_id == member.community_id
    end

    # TODO authorize only member in a network to see its discussions
    can [:create, :read, :follow, :unfollow, :tags], Discussion do |discussion|
      discussion.network.community_id == member.community_id
    end

    case member.role
    when 'administrator'
      can :administrate, [:application, Member, Company, Event, Network]

      can :manage, Network
      cannot :destroy, Network do |network|
        network.last_in_community?
      end
      can :manage, [:calendar, Position, Event, Company, SocialMediaLink, Availability]
      can :manage, Community, id: member.community_id
      can :manage, Discussion do |discussion|
        discussion.network.community_id == member.community_id
      end

      can :manage, Comment do |comment|
        comment.discussion.network.community_id == member.community_id
      end

      can([:manage_company, :invite_company_member, :manage_members_positions],
          Company)

      can :create, Member
      can_invite :administrator, :staff, :mentor, :regular_member
      can :resend_invitation, Member
      can :update, Member, role: ['administrator', 'staff', 'mentor', '', nil]
      can :destroy, Member, role: ['administrator', 'staff', 'mentor', '', nil]
    when 'staff'
      can :administrate, [:application, Member, Company, Event, Network]

      can :manage, Network
      cannot :destroy, Network do |network|
        network.last_in_community?
      end
      can :manage, [Position, Event]

      can([:create, :update, :manage_company, :invite_company_member, :manage_members_positions], Company)
      cannot :destroy, Company

      can :create, Member
      can_invite :mentor, :regular_member
      can :resend_invitation, Member
      can :update, Member, role: ['mentor', '', nil]
      can :destroy, Member, role: ['mentor', '', nil]
    when 'mentor'
    else # a regular Member
      can([:manage_company,
           :invite_company_member,
           :manage_members_positions,
           :update], Company) do |company|
        member.companies.founded.include?(company)
      end

      can :create, Member do |new_member|
        new_member.positions.map(&:company).uniq.any? &&
          (new_member.positions.map(&:company).uniq -
            member.companies.founded).empty?
      end
    end
  end
end
