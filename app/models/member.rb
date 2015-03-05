class Member < ActiveRecord::Base
  ROLES = %i(administrator staff mentor)

  mount_uploader :avatar, AvatarUploader

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :validatable,
         :recoverable, :rememberable, :trackable, :registerable,
         :confirmable, validate_on_invite: true

  validates :first_name, :last_name, :time_zone, presence: true, on: :update
  validates :role, inclusion: { in: ROLES.map(&:to_s) }, allow_blank: true

  # Associations
  belongs_to :community

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
      return if companies_positions.find(&:approved).present?
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
end
