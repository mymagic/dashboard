class SocialMediaLink < ActiveRecord::Base
  # Constants
  SERVICES = %w(
    about_me facebook twitter angel_list flickr quora crunch_base
    foursquare google_plus identica skype linked_in pinterest instagram
  )

  # Associations
  belongs_to :attachable, polymorphic: true

  # Validations
  validates :attachable, :service, :handle, presence: true
  validates :service, inclusion: { in: SERVICES }
  validates :handle, uniqueness: { scope: :service }
end
