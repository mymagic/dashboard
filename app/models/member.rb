class Member < ActiveRecord::Base
  ROLES = %i(administrator staff mentor)

  class AlreadyExistsError < StandardError
    def message
      "Member already exists"
    end
  end

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
  validates :email, format: { with: Devise.email_regexp }, allow_blank: true, if: :email_changed?
  validates :email, uniqueness: { scope: :community_id }, allow_blank: true, if: :email_changed?

  validates :password, presence: true, confirmation: true, if: :password_required?
  validates :password, length: { within: Devise.password_length }, allow_blank: true

  # Associations
  belongs_to :community
  has_many :social_media_links, as: :attachable

  scope :ordered, -> { order(last_name: :asc) }
  scope :invited, -> { where.not(invitation_token: nil) }
  scope :active, -> {
    where(invitation_token: nil).where.not(confirmed_at: nil)
  }

  accepts_nested_attributes_for :social_media_links, reject_if: :all_blank, allow_destroy: true

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
               class: CompaniesMembersPosition,
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
      errors.add(:companies_positions, :must_have_at_least_one_approved_companies_positions)
    end
  end

  concerning :OfficeHours do
    included do
      has_many :office_hours_as_mentor, class: OfficeHour, foreign_key: :mentor_id
      has_many(:office_hours_as_participant,
               class: OfficeHour,
               foreign_key: :participant_id)

      accepts_nested_attributes_for :office_hours_as_mentor
    end
  end

  concerning :Messages do
    included do
      def messages
        Message.where("sender_id = :id OR receiver_id = :id", id: id)
      end

      def messages_with(participant)
        Message.where(
          [
            "(sender_id = :my_id AND receiver_id = :participant_id) ",
            "OR (sender_id = :participant_id AND receiver_id = :my_id)"
          ].join(''), my_id: id, participant_id: participant.id
        )
      end

      def last_chat_participant
        last_message = Message.where("sender_id = :id OR receiver_id = :id", id: id).last

        if last_message
          last_message.sender_id == id ? last_message.receiver : last_message.sender
        else
          Member.where("community_id = :community_id AND id != :id", community_id: community_id, id: id).first
        end
      end
    end
  end

  protected

  def password_required?
    !skip_password && (!persisted? || !password.nil? || !password_confirmation.nil?)
  end
end
