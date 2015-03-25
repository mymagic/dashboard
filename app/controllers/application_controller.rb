class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_devise_permitted_parameters, if: :devise_controller?
  before_action :current_community
  before_action :authorize_community!

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

    if params[:controller] == 'registrations' && params[:action] == 'update'
      devise_parameter_sanitizer.for(:account_update) do |u|
        u.permit(account_update_params)
      end
    end

    if params[:controller] == 'invitations' && params[:action] == 'update'
      devise_parameter_sanitizer.for(:accept_invitation) do |u|
        u.permit(accept_invitation_params)
      end
    end

    if params[:controller] == 'sessions'
      devise_parameter_sanitizer.for(:sign_in) do |u|
        u.permit(sign_in_params)
      end
    end
  end

  rescue_from CanCan::AccessDenied do |exception|
    if current_member.nil?
      session[:next] = request.fullpath
      redirect_to login_url, :alert => "You have to log in to continue."
    else
      if request.env["HTTP_REFERER"].present?
        redirect_to :back, :alert => exception.message
      else
        if current_community
          redirect_to community_url(current_community), :alert => exception.message
        else
          redirect_to root_url, :alert => exception.message
        end
      end
    end
  end
end
