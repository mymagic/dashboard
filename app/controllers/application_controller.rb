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

  add_flash_types :warning

  layout :application_unless_xhr

  protected

  def application_unless_xhr
    request.xhr? ? false : 'application'
  end

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
    member_params = [
      :first_name,
      :last_name,
      :avatar,
      :avatar_cache,
      :time_zone,
      :password,
      :password_confirmation,
      :description,
      notifications: NotificationMailer.action_methods.map(&:to_sym),
      social_media_links_attributes: [:id, :_destroy, :url, :service]
    ]

    case params[:controller]
    when 'registrations'
      member_params.push(:current_password, :email)
      devise_parameter_sanitizer.for(:account_update) do |u|
        u.permit(member_params)
      end
    when 'invitations'
      member_params.push(:invitation_token)
      devise_parameter_sanitizer.for(:accept_invitation) do |u|
        u.permit(member_params)
      end
    when 'sessions'
      member_params.push(:community_id)
      devise_parameter_sanitizer.for(:sign_in) do |u|
        u.permit(member_params)
      end
    end
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
