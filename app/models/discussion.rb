class Discussion < ActiveRecord::Base
  # Associations
  belongs_to :community
  belongs_to :author, class: Member

  has_many :follows, as: :followable, dependent: :destroy, inverse_of: :followable
  has_many :followers, through: :follows, source: :member, class: Member

  before_validation :set_community, if: :author
  before_validation :set_author_as_follower, on: :create, if: :author

  validates :title, :body, :author, :community, presence: true
  validate :ensure_author_follows, on: :create

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
