module ApplicationHelper
  def favicon_path
    if current_community
     current_community.logo.url
    else
       image_path('missing/community/icon_default.png')
    end
  end
end
