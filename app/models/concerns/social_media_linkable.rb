module SocialMediaLinkable
  extend ActiveSupport::Concern

  included do
    has_many :social_media_links, as: :attachable, autosave: true
    before_save :mark_empty_social_media_links_for_destruction

    accepts_nested_attributes_for(
      :social_media_links,
      reject_if: ->(service) { service[:id].blank? && service[:url].blank? })
  end

  private

  def mark_empty_social_media_links_for_destruction
    social_media_links.each do |service|
      service.mark_for_destruction if service.url.blank?
    end
  end
end
