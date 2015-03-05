class CompaniesMembersPosition < ActiveRecord::Base
  belongs_to :member, inverse_of: :companies_positions
  belongs_to :company
  belongs_to :position

  validates :member, :company, :position, presence: true

  scope :manageable, -> { where(can_manage_company: true) }
  scope :approved, -> { where(approved: true) }

  def possible_positions_for_member
    Position.all_possible(member: member, company: company)
  end
end
