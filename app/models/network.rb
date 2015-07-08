class Network < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name, use: :slugged

  belongs_to :community

  validates :name, :slug, presence: true, uniqueness: true

  has_many :members, through: :networks

  scope :ordered, -> { order(name: :desc) }

  def last_in_community?
    community.networks.size == 1
  end
end
