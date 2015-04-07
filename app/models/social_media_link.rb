class SocialMediaLink < ActiveRecord::Base
  # Associations
  belongs_to :attachable, polymorphic: true

  # Validations
  validates :attachable, :service, :handle, presence: true
  validates :service, inclusion: { in: proc { |record| record.attachable.community.social_media_services } }
  validates :handle, uniqueness: { scope: :service }
end
