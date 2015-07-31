class Discussion < ActiveRecord::Base
  include Taggable
  include Followable

  paginates_per 25

  # Associations
  belongs_to :community
  belongs_to :author, class_name: 'Member', counter_cache: true

  has_many :comments, dependent: :destroy

  has_many :nested_comments, -> { ordered }, class_name: 'Comment'

  has_many :following_activities,
           class_name: 'Activity::Following',
           as: :resource,
           dependent: :destroy

  before_validation :set_community, if: :author
  before_validation :set_author_as_follower, on: :create, if: :author

  validates :title, :body, :author, :community, presence: true
  validate :ensure_author_follows, on: :create

  after_create :create_activity
  after_create :send_notifications

  FILTERS = %i(recent hot popular unanswered).freeze
  scope :filter_by, ->(filter) do
    case filter.try(:to_sym)
    when :unanswered
      where(comments_count: [nil, 0]).order(created_at: :desc)
    when :hot
      filter_by(:popular).where(created_at: 2.weeks.ago..Time.zone.now)
    when :popular
      order(follows_count: :desc)
    when :recent
      order(created_at: :desc)
    end
  end

  protected

  def create_activity
    Activity::Discussing.create(owner: author, discussion: self)
  end

  def set_community
    self.community = author.community
  end

  def set_author_as_follower
    followers << author
  end

  def ensure_author_follows
    return if followers.include? author
    errors.add(:author, 'should be following the discussion.')
  end

  def send_notifications
    community.members.active.where.not(id: author).find_each do |receiver|
      Notifier.deliver(
        :discussion_notification,
        receiver,
        author: author,
        discussion: self)
    end
  end
end
