module SocialMediaLinksHelper
  def social_media_links(resource)
    existing_services = resource.social_media_links.map(&:service)
    services = current_community.social_media_services - existing_services
    services.each do |service|
      resource.social_media_links.build(service: service)
    end
    resource.social_media_links
  end

  def social_media_icon_or_text(social_media_service)
    return social_media_service unless
      SocialMediaLink::DEFAULTS.include?(social_media_service)

    social_media_icon(social_media_service)
  end

  def social_media_icon(service)
    image_tag(
      "social_media_services/#{ service }.png",
      alt: service,
      title: service)
  end
end
