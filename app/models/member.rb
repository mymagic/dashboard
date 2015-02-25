class Member < ActiveRecord::Base
  ROLES = %i(administrator staff mentor)

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable, validate_on_invite: true

  validates :first_name, :last_name, :time_zone, presence: true

  has_many(:companies_positions,
           class: CompaniesMembersPosition,
           dependent: :destroy,
           inverse_of: :member)
  has_many :companies, -> { uniq }, through: :companies_positions
  has_many :positions, through: :companies_positions

  has_many(:approved_companies_positions,
           -> { approved },
           class: CompaniesMembersPosition,
           dependent: :destroy)
  has_many :approved_companies, -> { uniq }, source: :company, through: :approved_companies_positions
  has_many :approved_positions, source: :position, through: :approved_companies_positions

  accepts_nested_attributes_for(:companies_positions,
                                allow_destroy: true,
                                reject_if: proc do |attributes|
                                  attributes[:company_id].blank? &&
                                    attributes[:position_id].blank?
                                end)

  has_many :office_hours_as_mentor, class: OfficeHour, foreign_key: :mentor_id
  has_many(:office_hours_as_participant,
           class: OfficeHour,
           foreign_key: :participant_id)

  accepts_nested_attributes_for :office_hours_as_mentor

  mount_uploader :avatar, AvatarUploader

  scope :ordered, -> { order(last_name: :asc) }
  scope :invited, -> { where.not(invitation_token: nil) }
  scope :active, -> {
    where(invitation_token: nil).where.not(confirmed_at: nil)
  }

  ROLES.map(&:to_s).each do |is_role|
    define_method "#{ is_role }?" do
      role == is_role
    end
  end

  def approved_companies_and_positions
    approved_companies_positions.
      sort_by(&:position_priority_order).
      each_with_object({}) do |comp_pos, company_and_positions|
      company_and_positions[comp_pos.company] ||= []
      company_and_positions[comp_pos.company] << comp_pos.position
    end
  end

  def full_name
    "#{ first_name } #{ last_name }"
  end
end
