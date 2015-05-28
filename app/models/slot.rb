class Slot < ActiveRecord::Base
  # Accessors
  attr_accessor :available
  
  # Associations
  belongs_to :member
  belongs_to :availability

  # Validations
  validates :start_time, :end_time, :member, :availability, presence: true

  # Callbacks
  before_validation :add_member

  protected

  def add_member
    self.member = availability.member
  end
end
