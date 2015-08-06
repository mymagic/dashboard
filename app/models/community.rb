class Community < ActiveRecord::Base
  # Concerns
  extend FriendlyId

  # Behaviors
  friendly_id :name, use: :slugged
  mount_uploader :logo, LogoUploader

  # Associations
  has_many :companies,      dependent: :destroy
  has_many :members,        dependent: :destroy
  has_many :positions,      dependent: :destroy
  has_many :social_media_links, dependent: :destroy
  has_many :networks, dependent: :destroy
  has_many :events, through: :networks

  # Validations
  validates :name, :slug, presence: true
  validates :name, :slug, uniqueness: true
  validates :email, presence: true

  # Callbacks
  after_save :destroy_social_media_services,
             if: -> { social_media_services_changed? }
  after_save :create_default_network, on: :create
  before_validation :set_default_email, on: :create
  before_validation :populate_with_default_social_media_services, on: :create

  include NetworksConcern
  
  # Exception classes
  class CommunityNotFound < StandardError
  end

  def social_media_services=(values)
    if values.is_a? String
      values = values.split(',').map(&:strip).select(&:present?)
    end
    super(values)
  end

  protected

  def create_default_network
    self.networks.create(name: "#{ name }-network")
  end

  def destroy_social_media_services
    social_media_services_change.inject(:-).each do |service|
      social_media_links.where(service: service).destroy_all
    end
  end

  def populate_with_default_social_media_services
    self.social_media_services = SocialMediaLink::DEFAULTS
  end

  def set_default_email
    hostname = Rails.configuration.action_mailer.default_url_options[:host]
    self.email = "noreply@#{ hostname }"
  end
end
