class OfficeHour < ActiveRecord::Base
  validates :mentor, :time, presence: true
  validate :cannot_book_own_office_hour

  belongs_to :participant, class: Member
  belongs_to :mentor, class: Member

  scope :available, -> { where(participant: nil) }
  scope :booked,    -> { where.not(participant: nil) }

  private

  def cannot_book_own_office_hour
    return unless participant == mentor
    errors.add(:participant, :cannot_book_own_office_hour)
  end
end
