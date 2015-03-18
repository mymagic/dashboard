class Position < ActiveRecord::Base
  include RankedModel
  ranks :priority_order

  validates :name, presence: true, uniqueness: :true

  has_many :companies_members_positions, dependent: :destroy
  belongs_to :community

  scope :ordered, -> { rank(:priority_order) }

  def self.positions_with_members(company:)
    CompaniesMembersPosition.
      approved.
      includes(:member, :position).
      where(company_id: company, members: { invitation_token: nil }).
      where.not(members: { confirmed_at: nil }).
      order('positions.priority_order ASC').
      each_with_object({}) do |member_position, position_and_members|
        position_and_members[member_position.position] ||= []
        position_and_members[member_position.position] << member_position.member
      end
  end

  def self.positions_in_companies(member:)
    CompaniesMembersPosition.
      approved.
      where(member: member).
      includes(:position).
      order('positions.priority_order ASC').
      each_with_object({}) do |comp_pos, company_and_positions|
        company_and_positions[comp_pos.company] ||= []
        company_and_positions[comp_pos.company] << comp_pos.position
      end
  end

  def self.all_possible(member:, company:)
    ordered.where.not(
      id: member.companies_positions.where(company: company).pluck(:position_id)
    )
  end
end
