class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_devise_permitted_parameters, if: :devise_controller?
  before_action :current_community
  before_action :authorize_community!

  rescue_from CanCan::AccessDenied, with: :access_denied
  rescue_from Community::CommunityNotFound, with: :community_not_found

  helper_method :current_community

  protected

  def current_community
    return unless params[:community_id]
    @current_community ||= Community.friendly.find(params[:community_id])
  end

  def current_ability
    @current_ability ||= Ability.new(current_member)
  end

  def authorize_community!
    return if current_community.nil?
    authorize! :read, current_community
  end

  def configure_devise_permitted_parameters
    member_params = %i(first_name last_name avatar avatar_cache time_zone
                       password password_confirmation)
    account_update_params    = member_params.push(:current_password, :email)
    accept_invitation_params = member_params.push(:invitation_token)
    sign_in_params           = member_params.push(:community_id)

    case params[:controller]
    when 'registrations'
      devise_parameter_sanitizer.for(:account_update) do |u|
        u.permit(account_update_params)
      end if params[:action] == 'update'
    when 'invitations'
      devise_parameter_sanitizer.for(:accept_invitation) do |u|
        u.permit(accept_invitation_params)
      end if params[:action] == 'update'
    when 'sessions'
      devise_parameter_sanitizer.for(:sign_in) do |u|
        u.permit(sign_in_params)
      end
    end
  end

  def after_sign_out_path_for(_resource_or_scope)
    current_community ? community_path(current_community) : root_path
  end

  def access_denied(exception)
    if current_member
      msg = exception.message
      url = if request.env["HTTP_REFERER"].present?
              :back
            else
              community_path(current_member.community)
            end
    else
      msg = "You have to log in to continue."
      url = if current_community
              new_member_session_path(current_community)
            else
              root_path
            end
      session[:next] = request.fullpath
    end
    redirect_to url, alert: msg
  end

  def community_not_found
    redirect_to root_url, alert: 'Community does not exist.'
  end
end
