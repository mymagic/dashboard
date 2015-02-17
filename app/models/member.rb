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
end
