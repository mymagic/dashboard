class SocialMediaLink < ActiveRecord::Base
  DEFAULTS = %w(
    behance
    dribble
    facebook
    forrst
    googleplus
    instagram
    lastfm
    linkedin
    mail
    picasa
    pintrest
    rss
    skype
    tumbler
    twitter
    vimeo
    weheartit
    youtube
  ).freeze

  # Associations
  belongs_to :attachable, polymorphic: true
  belongs_to :community

  # Validations
  validates :attachable, :service, :community, presence: true
  validates :service,
            inclusion: {
              in: -> (record) { record.community.social_media_services }
            },
            if: -> (record) { record.community.present? }
  validates :service,
            uniqueness: {
              scope: [:attachable_id, :attachable_type, :community_id]
            }
  validates :url,
            format: {
              with: URI::regexp(%w(http https mailto)),
              message: 'is not a valid URL'
            },
            allow_blank: true

  # Callbacks
  before_validation :set_community, if: :attachable

  def as_icon?
    DEFAULTS.include?(service)
  end

  protected

  def set_community
    self.community = attachable.community
  end
end
