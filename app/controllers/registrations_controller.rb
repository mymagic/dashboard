class RegistrationsController < Devise::RegistrationsController
  include UploadConcern

  def new
    head :forbidden
  end

  def edit
  end

  def create
    head :forbidden
  end

  protected

  def resource_to_upload
    current_member.avatar
  end

  def update_resource(resource, params)
    resource.update_without_password(params)
  end

  def after_update_path_for(member)
    [member.community, member.default_network , member]
  end
end
