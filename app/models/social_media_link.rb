class SocialMediaLink < ActiveRecord::Base
  # Associations
  belongs_to :attachable, polymorphic: true
  belongs_to :community

  # Validations
  validates :attachable, :service, :handle, presence: true
  validates :service, inclusion: { in: proc { |record| record.attachable.community.social_media_services } }
  validates :handle, uniqueness: { scope: [:service, :attachable_id, :attachable_type, :community_id] }

  # Callbacks
  before_save :set_community

  protected

  def set_community
    self.community = attachable.community
  end
end
