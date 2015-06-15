class Ability
  include CanCan::Ability

  def can_invite(*member_types)
    member_types.map do |member_type|
      can "invite_#{ member_type }".to_sym, :members
    end
  end

  def create_positions(member)
    cannot :create, Position
    can :have, Position
    can :create, Position, member_id: member.id
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
    cannot :manage, :all
    cannot :read, :all
    cannot :administrate, :application
    cannot :invite_employee, Company
    cannot :manage_company, Company
    cannot :invite_company_member, Company
    cannot :have, Position

    can :read, Activity

    can :read, Community

    case member.role
    when 'administrator'
      can :administrate, :application

      can :manage, Community, id: member.community_id

      can :manage, :calendar

      can :manage, Position

      can :read, Availability
      can :manage, Availability, member_id: member.id

      can :read, Slot
      manage_slots(member)
      reserve_slots(member)

      can :manage, SocialMediaLink

      can :manage, Company
      can :manage_company, Company
      can :invite_company_member, Company
      can :manage_members_positions, Company

      can :administrate, Member
      can [:create, :read], Member
      can_invite :administrator, :staff, :mentor, :regular_member
      can :resend_invitation, Member
      can :update, Member, role: ['administrator', 'staff', 'mentor', '', nil]
      can :destroy, Member, role: ['administrator', 'staff', 'mentor', '', nil]
      can [:follow, :unfollow], Member do |other_member|
        other_member.id != member.id
      end

      can :search, Message
      create_messages(member)
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
      can :administrate, [Member, Company]

      can [:create, :read, :update], Company
      cannot :destroy, Company
      can :manage_company, Company
      can :invite_company_member, Company
      can :manage_members_positions, Company

      create_positions(member)
      can :manage, Position

      can :read, :calendar

      can [:create, :read], Member
      can_invite :mentor, :regular_member
      can :resend_invitation, Member
      can :update, Member, role: ['mentor', '', nil]
      can :destroy, Member, role: ['mentor', '', nil]
      can [:follow, :unfollow], Member do |other_member|
        other_member.id != member.id
      end

      can :read, Availability
      can :manage, Availability, member_id: member.id

      can :read, Slot
      manage_slots(member)
      reserve_slots(member)

      manage_social_media_links(member)

      can :search, Message
      create_messages(member)
      read_messages(member)

      can([:create, :read, :follow, :unfollow, :tags],
          Discussion,
          community_id: member.community_id)
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

      can :read, Availability
      can :manage, Availability, member_id: member.id

      can :read, Slot
      manage_slots(member)
      reserve_slots(member)

      manage_social_media_links(member)

      can :search, Message
      create_messages(member)
      read_messages(member)

      can([:create, :read, :follow, :unfollow, :tags],
          Discussion,
          community_id: member.community_id)

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
      can([:manage_company,
           :invite_company_member,
           :manage_members_positions,
           :update], Company) do |company|
        member.companies.founded.include?(company)
      end

      create_positions(member)

      can [:approve, :reject, :update], Position do |cmp|
        member.companies.founded.include? cmp.company
      end

      can :read, Member
      can :create, Member do |new_member|
        new_member.positions.map(&:company).uniq.any? &&
          (new_member.positions.map(&:company).uniq -
            member.companies.founded).empty?
      end
      can [:follow, :unfollow], Member do |other_member|
        other_member.id != member.id
      end

      can :read, Availability
      can :manage, Availability, member_id: member.id

      can :read, Slot
      manage_slots(member)
      reserve_slots(member)

      manage_social_media_links(member)

      can :search, Message
      create_messages(member)
      read_messages(member)

      can([:create, :read, :follow, :unfollow, :tags],
          Discussion,
          community_id: member.community_id)
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
