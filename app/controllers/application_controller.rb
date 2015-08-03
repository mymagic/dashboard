class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :force_ssl_connection, :unless => 'request.ssl?'
  before_action :configure_devise_permitted_parameters, if: :devise_controller?
  before_action :current_community
  before_action :authorize_through_magic_connect!
  before_action :authorize_community!

  rescue_from CanCan::AccessDenied, with: :access_denied
  rescue_from Community::CommunityNotFound, with: :community_not_found

  helper_method :current_community, :current_network, :magic_connect_path

  add_flash_types :warning

  layout :application_unless_xhr

  protected

  def magic_connect_logout_path
    "http://connect.mymagic.my/logout"
  end

  def magic_connect?
    cookies["magic_cookie"].present?
  end

  def magic_connect_path(redirect_to = nil)
    magic_connect_login = URI.parse("http://connect.mymagic.my/login")
    return magic_connect_login.to_s unless redirect_to
    magic_connect_login.query = "redirect_uri=#{ redirect_to }"
    magic_connect_login.to_s
  end

  def magic_connect_email
    return unless magic_connect?
    Base64.decode64(cookies["magic_cookie"]).split('|||').try(:second)
  end

  def magic_connect_id
    return unless magic_connect?
    Base64.decode64(cookies["magic_cookie"]).split('|||').try(:first).try(:to_i)
  end

  def magic_connect_member
    current_community.members.find_by_email(magic_connect_email)
  end

  def authorize_through_magic_connect!
    return if member_signed_in? || current_community.blank? || !magic_connect?
    return not_authorized unless magic_connect_member

    magic_connect_member.update_magic_connect_id!(magic_connect_id)
    flash.delete(:alert) # remove the alert messages (eg "you need to sign in")
    if magic_connect_member.confirmed?
      sign_in magic_connect_member
      reset_current_ability
    else
      redirect_to accept_invitation_url(
        magic_connect_member,
        magic_connect_member.community,
        invitation_token: magic_connect_member.invitation_token)
    end
  end

  def application_unless_xhr
    request.xhr? ? false : 'application'
  end

  def current_network
    @current_network ||= params[:network_id] ? Network.friendly.find(params[:network_id]) : nil
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
      :description,
      notifications: NotificationMailer.action_methods.map(&:to_sym),
      social_media_links_attributes: [:id, :_destroy, :url, :service]
    ]

    case params[:controller]
    when 'registrations'
      member_params.push(:email)
      devise_parameter_sanitizer.for(:account_update) do |u|
        u.permit(member_params)
      end
    when 'invitations'
      member_params.push(:invitation_token, :has_magic_connect_account)
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

  def not_authorized
    redirect_to root_path, alert: 'You are not authorized to access this page.'
  end

  def community_not_found
    redirect_to root_url, alert: 'Community does not exist.'
  end

  def force_ssl_connection
    return if ENV['FORCE_SSL'] == 'false'
    if ENV['FORCE_SSL'] == 'true' || Rails.env.production? || Rails.env.staging?
      redirect_to :protocol => 'https', :params => request.GET
    end
  end

  def reset_current_ability
    @current_ability = nil
    @current_user = nil
  end

end
