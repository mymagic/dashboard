class RegistrationsController < Devise::RegistrationsController
  before_action :set_javascript_variables, only: [:edit, :update]

  def new
    head :forbidden
  end

  def edit
  end

  def create
    head :forbidden
  end

  protected

  def set_javascript_variables
    s3_direct_upload_data = current_member.avatar.s3_direct_upload_data
    gon.directUploadUrl = s3_direct_upload_data.url
    gon.directUploadFormData = s3_direct_upload_data.fields
    gon.model = "member"
  end

  def update_resource(resource, params)
    if params[:password].blank? && params[:password_confirmation].blank?
      resource.update_without_password(params.except(:current_password))
    else
      resource.update_with_password(params)
    end
  end

  def after_update_path_for(member)
    community_member_path(member.community, member)
  end
end
