class Position < ActiveRecord::Base
  include RankedModel
  ranks :priority_order

  validates :name, presence: true, uniqueness: :true

  has_many(:companies_members,
           class: CompaniesMembersPosition,
           dependent: :destroy,
           inverse_of: :position)
  has_many :companies, -> { uniq }, through: :companies_members
  has_many :members, -> { uniq }, through: :companies_members

  scope :ordered, -> { rank(:priority_order) }
end
