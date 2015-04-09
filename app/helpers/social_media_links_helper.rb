module SocialMediaLinksHelper
  def social_link(social_media_link)
    handle = social_media_link.handle
    service = social_media_link.service

    if handle =~ URI::regexp(%w(http https))
      link_to(handle, handle, target: '_blank')
    else
      handle
    end
  end
end
