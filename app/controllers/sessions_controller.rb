class SessionsController < Devise::SessionsController
  protected

  def after_sign_in_path_for(resource)
    community_path(resource.community)
  end
end
