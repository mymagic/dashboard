class Position < ActiveRecord::Base

  class AlreadyExistsError < StandardError
    def message
      "Member already has this position in the company."
    end
  end

  validates :member, :company, :community, presence: true

  belongs_to :community
  belongs_to :member, inverse_of: :positions
  belongs_to :company

  before_validation :set_community, if: :member

  scope :founders, -> { where(founder: true) }

  def to_s
    return 'Founder' if founder?
    return role if role.present?
    'Team Member'
  end

  protected

  def set_community
    self.community = member.community
  end
end
