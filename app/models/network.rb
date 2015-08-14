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

  def availabilities_for_show
    Rails.cache.fetch(cache_key_for_availabilities) do
      availabilities.
        joins(:member).
        by_daterange(Date.today, 1.week.from_now.to_date).
        ordered
    end
  end

  def activities_for_show
    Rails.cache.fetch(cache_key_for_activites) do
      activities.includes(:owner).ordered.limit(20)
    end
  end

  private

  def base_cache_key
    "community/#{community_id}/networks/#{id}"
  end

  def cache_key_for_availabilities
    count          = availabilities.count
    max_updated_at = availabilities.
                     maximum(:updated_at).
                     try(:utc).
                     try(:to_s, :number)
    "#{base_cache_key}/availabilities-#{count}-#{max_updated_at}"
  end

  def cache_key_for_activites
    count          = activities.count
    max_updated_at = activities.
                     maximum(:updated_at).
                     try(:utc).
                     try(:to_s, :number)
    "#{base_cache_key}/activities-#{count}-#{max_updated_at}"
  end
end
