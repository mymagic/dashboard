module Admin
  class CommunitiesController < AdminController
    before_action :authorize_manage_community!
    before_action :set_javascript_variables, only: [:edit, :update]

    def edit
    end

    def update
      if @current_community.update_attributes(community_params)
        redirect_to(
          community_path(@current_community),
          notice: 'Settings were successfully updated.')
      else
        render 'edit', alert: 'Error updating community.'
      end
    end

    protected

    def set_javascript_variables
      s3_direct_upload_data = @current_community.logo.s3_direct_upload_data
      gon.directUploadUrl = s3_direct_upload_data.url
      gon.directUploadFormData = s3_direct_upload_data.fields
      gon.model = "community"
      gon.id = @current_community.id
    end

    def authorize_manage_community!
      authorize! :manage, current_community
    end

    def community_params
      params.
        require(:community).
        permit(:name, :logo, :email, :social_media_services)
    end
  end
end
