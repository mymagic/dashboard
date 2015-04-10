module SocialMediaLinksHelper
  def social_link(social_media_link)
    handle = social_media_link.handle
    service = social_media_link.service.camelize

    if handle =~ URI::regexp(%w(http https))
      service, handle = link_to(service, handle, target: '_blank'), ''
    end

    definition_list(service => handle)
  end
end
