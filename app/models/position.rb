class Position < ActiveRecord::Base
  include RankedModel
  ranks :priority_order

  validates :name, :priority_order, presence: true
  validates :name, uniqueness: :true

  has_many(:companies_members,
           class: CompaniesMembersPosition,
           dependent: :destroy,
           inverse_of: :position)
  has_many :companies, through: :companies_members
  has_many :members,   through: :companies_members

  scope :ordered, -> { rank(:priority_order) }
end
