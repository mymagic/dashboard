class RegistrationsController < Devise::RegistrationsController
  def new
    head :forbidden
  end

  def edit
  end

  def create
    head :forbidden
  end

  protected

  def update_resource(resource, params)
    if params[:password].blank? && params[:password_confirmation].blank?
      resource.update_without_password(params.except(:current_password))
    else
      resource.update_with_password(params)
    end
  end
end
