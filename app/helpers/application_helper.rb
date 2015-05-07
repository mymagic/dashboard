module ApplicationHelper
  def favicon_path
    return current_community.logo.url if current_community
    image_path('missing/community/icon_default.png')
  end
end
