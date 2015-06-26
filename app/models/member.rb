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

  has_many :discussions, foreign_key: :author_id, dependent: :destroy
  has_many :comments, foreign_key: :author_id, dependent: :destroy

  has_many :rsvps, dependent: :destroy
  has_many :events, through: :rsvps

  FILTERS = %i(everyone founders members mentors staff).freeze
  scope :filter_by, ->(filter) do
    case filter.try(:to_sym)
    when :members
      joins(:positions).where(positions: { founder: false })
    when :founders
      joins(:positions).where(positions: { founder: true })
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

  concerning :Registrations do
    def create_signup_activity
      Activity::Registering.create(owner: self, invited_by: invited_by)
    end
  end

  concerning :Activities do
    included do
      has_many :activities, foreign_key: :owner_id, dependent: :destroy
      has_many :following_activities,
               class_name: 'Activity::Following',
               as: :resource,
               dependent: :destroy
    end
  end

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
      validate :must_have_at_least_one_position

      has_many :positions, inverse_of: :member, dependent: :destroy
      has_many :companies, -> { uniq }, through: :positions do
        def founded
          where(positions: { founder: true })
        end
      end

      accepts_nested_attributes_for(
        :positions,
        allow_destroy: true,
        reject_if: proc do |attributes|
          attributes[:company_id].blank?
        end)

      def positions_in_companies
        positions.group_by(&:company)
      end
    end

    def can_invite_member_to_company?(company)
      can?(:invite_company_member, company) unless company.blank?
    end

    private

    def must_have_at_least_one_position
      return unless regular_member?
      return if positions.present?
      errors.add :positions, :must_have_at_least_one_position
    end
  end

  concerning :Availabilities do
    included do
      has_many :availabilities, dependent: :destroy
      scope :by_availability_date, ->(date) {
        joins(:availabilities).where(availabilities: { date: date }).uniq
      }
    end
  end

  concerning :Slots do
    included do
      has_many :slots, dependent: :destroy
    end
  end

  concerning :Messages do
    included do
      def messages
        Message.with(self)
      end

      def chat_participants
        Message.chat_participants_with_member(self)
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
        chat_participants.first
      end
    end
  end

  concerning :Notifications do
    def receive?(action)
      notifications[action.to_s] != "false"
    end

    # populate the notifications hash with "true" as default for each
    # notification action.
    def notifications
      settings = read_attribute(:notifications)
      NotificationMailer::NOTIFICATIONS.each_with_object({}) do |action, hash|
        hash[action] = settings[action] || "true"
      end
    end
  end

  protected

  def password_required?
    !skip_password &&
      (!persisted? || !password.nil? || !password_confirmation.nil?)
  end
end
