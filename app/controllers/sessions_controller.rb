class SessionsController < Devise::SessionsController
  # protected

  def new
    redirect_to magic_connect_path(magic_connect_redirect_url)
  end

  private

  def after_sign_out_path_for(_resource_or_scope)
    magic_connect_logout_path
  end

  def after_sign_in_path_for(resource)
    community_path(resource.community)
  end

  def magic_connect_redirect_url
    return community_url(current_community) unless session[:member_return_to]
    redirect_uri = URI.parse(request.url)
    redirect_uri.path = session[:member_return_to]
    redirect_uri
  end
end
