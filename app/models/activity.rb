class Activity < ActiveRecord::Base
  belongs_to :community
  belongs_to :owner, class_name: 'Member'
  belongs_to :resource, polymorphic: true
  belongs_to :secondary_resource, polymorphic: true

  validates :community, :owner, :resource, presence: true

  before_validation :set_community, if: :owner

  FILTERS = %i{public personal}.freeze

  scope :ordered, -> { order(updated_at: :desc) }
  scope :for, ->(member) do
    where(
      "activities.owner_id IN (:followed_members) OR "\
      "(activities.secondary_resource_id IN (:followed_discussions) "\
      "AND type = 'CommentActivity')",
      followed_members: member.followed_members.pluck(:id),
      followed_discussions: member.followed_discussions.pluck(:id)
    )
  end

  protected

  def set_community
    self.community = owner.community
  end
end
