class Discussion < ActiveRecord::Base
  include Taggable
  include Followable

  paginates_per 25

  # Associations
  belongs_to :community
  belongs_to :author, class_name: 'Member'

  has_many :comments, dependent: :destroy

  has_many :nested_comments, -> { ordered }, class_name: 'Comment'

  before_validation :set_community, if: :author
  before_validation :set_author_as_follower, on: :create, if: :author

  validates :title, :body, :author, :community, presence: true
  validate :ensure_author_follows, on: :create

  FILTERS = %i(recent hot popular unanswered).freeze
  scope :filter_by, ->(filter) do
    case filter.try(:to_sym)
    when :unanswered
      where(comments_count: [nil, 0]).order(created_at: :desc)
    when :hot
      filter_by(:popular).where(created_at: 2.weeks.ago..Time.now)
    when :popular
      order(follows_count: :desc)
    when :recent
      order(created_at: :desc)
    end
  end

  protected

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
end
