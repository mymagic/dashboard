class Follow < ActiveRecord::Base
  belongs_to :member
  belongs_to :followable, polymorphic: true, counter_cache: true

  validates :member, :followable, presence: true
  validates(
    :followable_id,
    uniqueness: { scope: [:member_id, :followable_type] }
  )

  validate :cannot_follow_yourself, if: -> { member && followable }

  after_create :create_activity

  private

  def create_activity
    FollowActivity.create(owner: member, followable: followable)
  end

  def cannot_follow_yourself
    return unless member == followable
    errors.add(:member, :cannot_follow_yourself)
  end
end
