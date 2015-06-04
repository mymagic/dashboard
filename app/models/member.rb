class Member < ActiveRecord::Base
  ROLES = %i(administrator staff mentor)

  class AlreadyExistsError < StandardError
    def message
      "Member already exists"
    end
  end

  include SocialMediaLinkable
  include Followable

  paginates_per 60

  mount_uploader :avatar, AvatarUploader

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable,
         :recoverable, :rememberable, :trackable, :registerable,
         :confirmable, validate_on_invite: true,
         authentication_keys: [:email, :community_id],
         invite_key: { email: Devise.email_regexp, community_id: /\d+/ }

  validates :first_name, :last_name, :time_zone, presence: true, on: :update
  validates :role, inclusion: { in: ROLES.map(&:to_s) }, allow_blank: true

  # Override Validatable module
  validates :email, :community, presence: true
  validates(
    :email,
    format: { with: Devise.email_regexp },
    allow_blank: true,
    if: :email_changed?)
  validates(
    :email,
    uniqueness: { scope: :community_id },
    allow_blank: true,
    if: :email_changed?)

  validates(
    :password, presence: true, confirmation: true, if: :password_required?)
  validates(
    :password, length: { within: Devise.password_length }, allow_blank: true)

  # Associations
  belongs_to :community

  has_many :follows, dependent: :destroy
  has_many(
    :followed_members,
    through: :follows,
    source: :followable,
    source_type: Member)
  has_many(
    :followed_discussions,
    through: :follows,
    source: :followable,
    source_type: Discussion)

  has_many :discussions, foreign_key: :author_id
  has_many :comments, foreign_key: :author_id

  has_many :rsvps, dependent: :destroy
  has_many :events, through: :rsvps

  scope :filter_by, ->(filter) do
    case filter.try(:to_sym)
    when :members
      where(role: ['', nil])
    when :mentors
      where(role: :mentor)
    when :staff
      where(role: [:staff, :administrator])
    end
  end

  scope :ordered, -> { order(last_name: :asc) }
  scope :invited, -> { where.not(invitation_token: nil) }
  scope :active, -> {
    where(invitation_token: nil).where.not(confirmed_at: nil)
  }

  def full_name
    "#{ first_name } #{ last_name }"
  end

  def to_param
    "#{ id }-#{ full_name.parameterize }"
  end

  def ability
    @ability ||= Ability.new(self)
  end
  delegate :can?, :cannot?, to: :ability

  concerning :Roles do
    included do
      def self.assignable_roles_for(member)
        roles = []
        roles << :administrator if member.can? :invite_administrator, :members
        roles << :staff         if member.can? :invite_staff, :members
        roles << :mentor        if member.can? :invite_mentor, :members
        roles
      end
    end

    ROLES.map(&:to_s).each do |is_role|
      define_method "#{ is_role }?" do
        role == is_role
      end
    end

    def can_assign_role?(role)
      return can?(:invite_regular_member, :members) if role.blank?
      Member.assignable_roles_for(self).include?(role.to_sym)
    end

    def regular_member?
      role.blank?
    end
  end

  concerning :Positions do
    included do
      validate :must_have_at_least_one_approved_companies_positions

      has_many(:companies_positions,
               class_name: 'CompaniesMembersPosition',
               dependent: :destroy,
               inverse_of: :member)

      accepts_nested_attributes_for(:companies_positions,
                                    allow_destroy: true,
                                    reject_if: proc do |attributes|
                                      attributes[:company_id].blank? &&
                                        attributes[:position_id].blank?
                                    end)
    end

    def positions_in_companies
      Position.positions_in_companies(member: self)
    end

    def can_invite_member_to_company?(company)
      can?(:invite_company_member, company) unless company.blank?
    end

    def manageable_companies
      companies_positions.
        includes(:company).
        manageable.
        approved.
        map(&:company).
        flatten.
        uniq
    end

    private

    def must_have_at_least_one_approved_companies_positions
      return unless regular_member?
      return if companies_positions.find(&:approver_id).present?
      errors.add(
        :companies_positions,
        :must_have_at_least_one_approved_companies_positions)
    end
  end

  concerning :OfficeHours do
    included do
      has_many :office_hours_as_mentor, class_name: 'OfficeHour', foreign_key: :mentor_id
      has_many(:office_hours_as_participant,
               class_name: 'OfficeHour',
               foreign_key: :participant_id)

      accepts_nested_attributes_for :office_hours_as_mentor
    end
  end

  concerning :Messages do
    included do
      def messages
        Message.with(self)
      end

      def chat_participants
        # It is equal to ..
        # self.class.find(
        #   messages.pluck(:sender_id, :receiver_id).flatten.uniq - [id])

        Member.joins([
          "INNER JOIN messages ON ",
          "(messages.sender_id = members.id OR "\
          "messages.receiver_id = members.id) ",
          "AND (messages.sender_id = #{id} OR messages.receiver_id = #{id})"
        ].join('')).where.not(id: id).uniq
      end

      def messages_with(participant)
        messages.with(participant)
      end

      def unread_messages_with(participants)
        Message.where(sender_id: participants, receiver_id: id).
          unread.
          group(:sender_id).
          select('sender_id, COUNT(*) AS unread_count').
          to_a
      end

      def last_chat_participant
        chat_participants.last
      end
    end
  end

  protected

  def password_required?
    !skip_password &&
      (!persisted? || !password.nil? || !password_confirmation.nil?)
  end
end
