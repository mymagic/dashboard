class RegistrationsController < Devise::RegistrationsController
  def new
    head :forbidden
  end

  def create
    head :forbidden
  end

  protected

  def update_resource(resource, params)
    resource.update_without_password(params)
  end
end
