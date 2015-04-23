class CompaniesMembersPosition < ActiveRecord::Base
  class AlreadyExistsError < StandardError
    def message
      "Member already has this position in the company."
    end
  end

  belongs_to :member, inverse_of: :companies_positions
  belongs_to :company
  belongs_to :position
  belongs_to :approver, class_name: 'Member'

  validates :member, :company, :position, presence: true

  validate :member_community_must_be_the_same_as_position_community

  scope :manageable, -> { where(can_manage_company: true) }
  scope :approved, -> { where.not(approver: nil) }
  scope :pending, -> { where(approver: nil) }

  def possible_positions_for_member
    Position.all_possible(member: member, company: company)
  end

  def members_last_manager_position_in_company?(the_member)
    return false unless can_manage_company && member == the_member
    the_member.
      companies_positions.
      where(company: company).
      manageable.
      approved.one?
  end

  private

  def member_community_must_be_the_same_as_position_community
    return unless member.present? && position.present? && member.community_id != position.community_id
    errors.add(:member, :community_must_be_the_same_as_position_community)
  end
end
