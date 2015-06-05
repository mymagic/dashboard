module SocialMediaLinksHelper
  def social_media_links(resource)
    existing_services = resource.social_media_links.map(&:service)
    services = current_community.social_media_services - existing_services
    services.each do |service|
      resource.social_media_links.build(service: service)
    end
    resource.social_media_links.sort_by(&:service)
  end
end
