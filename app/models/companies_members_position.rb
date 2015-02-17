class CompaniesMembersPosition < ActiveRecord::Base
  belongs_to :member
  belongs_to :company
  belongs_to :position

  validates :member, :company, :position, presence: true
  validates :member, uniqueness: { scope: [:company, :position] }

  delegate :name, to: :company, prefix: true
  delegate :name, to: :position, prefix: true
end
