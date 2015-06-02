module Admin
  class CommunitiesController < AdminController
    before_action :authorize_manage_community!

    def edit
    end

    def update
      if @current_community.update_attributes(community_params)
        redirect_to(
          community_path(@current_community),
          notice: 'Community was successfully updated.')
      else
        render 'edit', alert: 'Error updating community.'
      end
    end

    protected

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
