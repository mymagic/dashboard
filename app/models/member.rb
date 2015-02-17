class Member < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :confirmable

  validates :first_name, :last_name, presence: true

  has_many :companies_positions, class: CompaniesMembersPosition
  has_many :companies,  through: :companies_positions
  has_many :positions,  through: :companies_positions

  has_many :office_hours_as_mentor, class: OfficeHour, foreign_key: :mentor_id
  has_many(:office_hours_as_participant,
           class: OfficeHour,
           foreign_key: :participant_id)

  accepts_nested_attributes_for :office_hours_as_mentor
end
