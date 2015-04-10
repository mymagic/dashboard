class Community < ActiveRecord::Base
  # Concerns
  extend FriendlyId

  # Behaviors
  friendly_id :name, use: :slugged
  mount_uploader :logo, LogoUploader

  # Associations
  has_many :companies,    dependent: :destroy
  has_many :members,      dependent: :destroy
  has_many :positions,    dependent: :destroy
  has_many :office_hours, dependent: :destroy
  has_many :social_media_links, dependent: :destroy

  # Validations
  validates :name, :slug, presence: true
  validates :name, :slug, uniqueness: true

  # Callbacks
  after_save :destroy_social_media_services, if: -> { social_media_services_changed? }

  # Exception classes
  class CommunityNotFound < StandardError
  end

  def social_media_services=(values)
    values = values.split(',').map(&:strip).select(&:present?) if values.is_a? String
    super(values)
  end

  protected

  def destroy_social_media_services
    social_media_services_change.inject(:-).each do |service|
      social_media_links.where(service: service).destroy_all
    end
  end
end
