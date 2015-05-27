class Follow < ActiveRecord::Base
  belongs_to :member
  belongs_to :followable, polymorphic: true, counter_cache: true

  validates :member, :followable, presence: true
  validates :followable_id, uniqueness: { scope: [:member_id, :followable_type] }

  validate :cannot_follow_yourself, if: -> { member && followable }

  private

  def cannot_follow_yourself
    return unless member == followable
    errors.add(:member, :cannot_follow_yourself)
  end
end
