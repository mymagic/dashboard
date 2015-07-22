class Comment < ActiveRecord::Base
  belongs_to :author, class_name: 'Member'
  belongs_to :discussion, counter_cache: true

  before_validation :set_author_as_follower,
                    on: :create,
                    if: -> { author && discussion }

  validates :discussion, :body, :author, presence: true
  validate :ensure_author_follows, on: :create, if: -> { author && discussion }

  scope :ordered, -> { order(created_at: :asc) }

  after_create :create_activity
  after_create :send_notifications

  has_many :commenting_activities,
           class_name: 'Activity::Commenting',
           as: :resource,
           dependent: :destroy
  has_one :network, through: :discussion

  protected

  def send_notifications
    discussion.followers.where.not(id: author).find_each do |receiver|
      Notifier.deliver(
        :comment_notification,
        receiver,
        author: author,
        discussion: discussion)
    end
  end

  def create_activity
    Activity::Commenting.create(
      owner: author,
      comment: self,
      discussion: discussion)
  end

  def set_author_as_follower
    return if discussion.followers.include? author
    discussion.followers << author
  end

  def ensure_author_follows
    return if discussion.followers.include? author
    errors.add(:author, 'should be following the discussion.')
  end
end
