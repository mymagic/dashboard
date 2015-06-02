class Slot < ActiveRecord::Base
  # Accessors
  attr_accessor :available

  # Behaviors
  include TimeInZone
  time_in_zone_for :start_time, :end_time

  # Associations
  belongs_to :member
  belongs_to :availability

  # Delegations
  delegate :time_zone, to: :availability

  # Validations
  validates :start_time, :end_time, :availability, presence: true

  # Callbacks
  before_validation :add_member, if: :availability

  protected

  def add_member
    self.member = availability.member
  end
end
