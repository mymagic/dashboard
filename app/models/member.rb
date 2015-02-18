class Member < ActiveRecord::Base
  ROLES = %i(administrator)

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  validates :first_name, :last_name, presence: true

  has_many :companies_positions, class: CompaniesMembersPosition
  has_many :companies,  through: :companies_positions
  has_many :positions,  through: :companies_positions

  accepts_nested_attributes_for(:companies_positions,
                                allow_destroy: true,
                                reject_if: :all_blank)

  has_many :office_hours_as_mentor, class: OfficeHour, foreign_key: :mentor_id
  has_many(:office_hours_as_participant,
           class: OfficeHour,
           foreign_key: :participant_id)

  accepts_nested_attributes_for :office_hours_as_mentor

  ROLES.map(&:to_s).each do |is_role|
    define_method "#{ is_role }?" do
      role == is_role
    end
  end

  def company_and_positions
    companies_positions.
      each_with_object({}) do |comp_pos, company_and_positions|
      company_and_positions[comp_pos.company] ||= []
      company_and_positions[comp_pos.company] << comp_pos.position
    end
  end

  def full_name
    "#{ first_name } #{ last_name }"
  end
end
