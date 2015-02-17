class Company < ActiveRecord::Base
  validates :name, presence: true
  validates :description, length: { minimum: 5 }, allow_blank: true
  validates(
    :website,
    format: { with: URI::regexp(%w(http https)) },
    allow_blank: true)

  has_many :members_positions, class: CompaniesMembersPosition
  has_many :members,    through: :members_positions
  has_many :positions,  through: :members_positions
end
