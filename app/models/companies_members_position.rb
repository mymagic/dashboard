class CompaniesMembersPosition < ActiveRecord::Base
  belongs_to :member, inverse_of: :companies_positions
  belongs_to :company, inverse_of: :members_positions
  belongs_to :position, inverse_of: :companies_members

  validates :member, :company, :position, presence: true
  validates :position, uniqueness: { scope: [:company, :member], message: 'You can only have that position once per company.' }

  scope :approved, -> { where(approved: true) }
  scope :unapproved, -> { where.not(approved: true) }

  delegate :name, to: :company, prefix: true
  delegate :name, to: :position, prefix: true

  def positions_possible
    Position.ordered.where.not(
      id: member.companies_positions.where(company: company).pluck(:position_id))
  end

  def any_positions_possible?
    positions_possible.any?
  end
end
