class Position < ActiveRecord::Base
  validates :name, presence: true, uniqueness: :true

  has_many(:companies_members,
           class: CompaniesMembersPosition,
           dependent: :destroy)
  has_many :companies, through: :companies_members
  has_many :members,   through: :companies_members

  scope :ordered, -> { order(name: :desc) }
end
