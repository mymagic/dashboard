class Discussion < ActiveRecord::Base
  include Taggable

  paginates_per 10

  # Associations
  belongs_to :community
  belongs_to :author, class_name: 'Member'

  has_many :follows, as: :followable, dependent: :destroy, inverse_of: :followable
  has_many :followers, through: :follows, source: :member, class_name: 'Member'
  has_many :comments, dependent: :destroy

  has_many :nested_comments, -> { ordered }, class_name: 'Comment'

  before_validation :set_community, if: :author
  before_validation :set_author_as_follower, on: :create, if: :author

  validates :title, :body, :author, :community, presence: true
  validate :ensure_author_follows, on: :create

  scope :filter_by, ->(filter) do
    case filter.try(:to_sym)
    when :hot
      filter_by(:popular).where(created_at: 2.weeks.ago.utc..Time.now.utc)
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
