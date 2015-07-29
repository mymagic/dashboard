class InvitationsController < DeviseController
  skip_before_action :authorize_through_magic_connect!, only: [:edit, :update]
  prepend_before_filter :authenticate_inviter!, only: [:new, :create]
  prepend_before_filter :has_invitations_left?, only: [:create]
  prepend_before_filter :require_no_authentication, only: [:edit, :update, :destroy]
  prepend_before_filter :resource_from_invitation_token, only: [:edit, :destroy]

  include UploadConcern
  skip_before_action :set_upload_settings, only: :update

  helper_method :after_sign_in_path_for

  # GET /resource/invitation/new
  def new
    head :forbidden
  end

  # POST /resource/invitation
  def create
    head :forbidden
  end

  # GET /resource/invitation/accept?invitation_token=abcdef
  def edit
    resource.invitation_token = params[:invitation_token]
    resource.has_magic_connect_account = MagicConnect.user_exists?(resource.email)
    render :edit
  end

  # PUT /resource/invitation
  def update
    self.resource = accept_resource
    invitation_accepted = resource.errors.empty?

    yield resource if block_given?

    if invitation_accepted
      if resource.has_magic_connect_account == "false"
        resource.create_magic_connect_account!
      end
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message :notice, flash_message if is_flashing_format?
      sign_in(resource_name, resource)
      resource.create_signup_activity if resource.is_a? Member
      respond_with resource, location: after_accept_path_for(resource)
    else
      respond_with_navigational(resource) do
        set_upload_settings
        render :edit
      end
    end
  end

  # GET /resource/invitation/remove?invitation_token=abcdef
  def destroy
    resource.destroy
    set_flash_message :notice, :invitation_removed if is_flashing_format?
    redirect_to after_sign_out_path_for(resource_name)
  end

  protected

  def resource_to_upload
    gon.invitation_token = resource.invitation_token
    resource.avatar
  end

  def accept_resource
    resource_class.accept_invitation!(update_resource_params)
  end

  def current_inviter
    authenticate_inviter!
  end

  def has_invitations_left?
    unless current_inviter.nil? || current_inviter.has_invitations_left?
      self.resource = resource_class.new
      set_flash_message :alert, :no_invitations_remaining if is_flashing_format?
      respond_with_navigational(resource) { render :new }
    end
  end

  def resource_from_invitation_token
    unless params[:invitation_token] && self.resource = resource_class.find_by_invitation_token(params[:invitation_token], true)
      set_flash_message(:alert, :invitation_token_invalid) if is_flashing_format?
      redirect_to after_sign_out_path_for(resource_name)
    end
  end

  def invite_params
    devise_parameter_sanitizer.sanitize(:invite)
  end

  def update_resource_params
    devise_parameter_sanitizer.sanitize(:accept_invitation)
  end
end
