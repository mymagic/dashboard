class Network < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :community

  validates :name, :slug, presence: true, uniqueness: { scope: :community }

  has_many :memberships, dependent: :destroy
  has_many :members, through: :memberships
  has_many :activities
  has_many :discussions, dependent: :destroy
  has_many :tags, dependent: :destroy
  has_many :discussion_tags
  has_many :availabilities, dependent: :destroy
  has_many :events, dependent: :destroy
  has_and_belongs_to_many :companies

  scope :ordered, -> { order(name: :desc) }

  def last_in_community?
    community.networks.size == 1
  end
end
