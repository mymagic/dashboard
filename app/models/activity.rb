class Activity < ActiveRecord::Base
  belongs_to :network
  belongs_to :owner, class_name: 'Member'
  belongs_to :resource, polymorphic: true
  belongs_to :secondary_resource, polymorphic: true
  delegate :community, to: :network

  validates :network, :owner, :resource, presence: true

  before_validation :set_network

  FILTERS = %i(public personal).freeze

  scope :ordered, -> { order(updated_at: :desc) }
  scope :for, ->(member) do
    where(
      "activities.owner_id IN (:followed_members) OR "\
      "(activities.secondary_resource_id IN (:followed_discussions) "\
      "AND type = 'Activity::Commenting')",
      followed_members: member.followed_members.pluck(:id),
      followed_discussions: member.followed_discussions.pluck(:id)
    )
  end

  protected

  def set_network
    self.network ||= resource.try(:network)
  end
end
