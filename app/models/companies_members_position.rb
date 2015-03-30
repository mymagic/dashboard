class CompaniesMembersPosition < ActiveRecord::Base
  belongs_to :member, inverse_of: :companies_positions
  belongs_to :company
  belongs_to :position

  validates :member, :company, :position, presence: true

  validate :member_community_must_be_the_same_as_position_community

  scope :manageable, -> { where(can_manage_company: true) }
  scope :approved, -> { where(approved: true) }

  def possible_positions_for_member
    Position.all_possible(member: member, company: company)
  end

  private

  def member_community_must_be_the_same_as_position_community
    return unless member.present? && position.present? && member.community_id != position.community_id
    errors.add(:member, :community_must_be_the_same_as_position_community)
  end
end
