class Comment < ActiveRecord::Base
  belongs_to :author, class_name: 'Member'
  belongs_to :discussion, counter_cache: true

  before_validation :set_author_as_follower,
                    on: :create,
                    if: -> { author && discussion }

  validates :discussion, :body, :author, presence: true
  validate :ensure_author_follows, on: :create, if: -> { author && discussion }

  scope :ordered, -> { order(created_at: :asc) }

  protected

  def set_author_as_follower
    return if discussion.followers.include? author
    discussion.followers << author
  end

  def ensure_author_follows
    return if discussion.followers.include? author
    errors.add(:author, 'should be following the discussion.')
  end
end
