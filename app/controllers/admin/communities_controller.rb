module Admin
  class CommunitiesController < AdminController
    before_action :authorize_manage_community!

    include UploadConcern

    def edit
    end

    def update
      if @current_community.update_attributes(community_params)
        redirect_to(
          edit_community_admin_community_path(@current_community),
          notice: 'Settings were successfully updated.')
      else
        render 'edit', alert: 'Error updating community.'
      end
    end

    protected

    def resource_to_upload
      gon.id = @current_community.id
      @current_community.logo
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
