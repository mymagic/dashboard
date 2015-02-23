class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_action :configure_devise_permitted_parameters, if: :devise_controller?

  protected

  def current_ability
    @current_ability ||= Ability.new(current_member)
  end

  def configure_devise_permitted_parameters
    registration_params = [
      :first_name,
      :last_name,
      :email,
      :avatar,
      :avatar_cache,
      :password,
      :time_zone,
      :password_confirmation
    ]

    if params[:controller] = 'registrations' && params[:action] == 'update'
      devise_parameter_sanitizer.for(:account_update) do |u|
        u.permit(registration_params << :current_password)
      end
    end

    if params[:controller] = 'invitations' && params[:action] == 'update'
      devise_parameter_sanitizer.for(:accept_invitation) do |u|
        u.permit((registration_params << :invitation_token).except(:email))
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
        redirect_to root_url, :alert => exception.message
      end
    end
  end
end
