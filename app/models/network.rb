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
  has_and_belongs_to_many :companies
  has_and_belongs_to_many :events
  has_and_belongs_to_many :availabilities

  scope :ordered, -> { order(name: :desc) }

  def last_in_community?
    community.networks.size == 1
  end

  def availabilities_for_show
    Rails.cache.fetch(cache_key_for_availabilities) do
      availabilities.
        joins(:member).
        by_daterange(Date.today, 1.week.from_now.to_date).
        ordered
    end
  end

  def activities_for_show
    Rails.cache.fetch(cache_key_for_activities) do
      activities.includes(:owner).ordered.limit(20)
    end
  end

  private

  def base_cache_key
    "/networks/#{id}/#{updated_at.to_i}"
  end

  [:availabilities, :activities].each do |relation|
    define_method "cache_key_for_#{ relation }" do
      "#{base_cache_key}/#{relation}"
    end
  end
end
