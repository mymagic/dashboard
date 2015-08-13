class Membership < ActiveRecord::Base
  belongs_to :member
  belongs_to :network

  validates :member, :network, presence: true
  validates :member_id, uniqueness: { scope: :network_id }
end
