module Admin
  class NetworksController < AdminController
    load_and_authorize_resource through: :current_community, find_by: :slug

    def index
      @networks = @networks.ordered.page params[:page]
    end

    def new
      render 'admin/networks/form'
    end

    def create
      if @network.save
        redirect_to_admin_networks_path('Network was successfully created.')
      else
        render 'admin/networks/form', alert: 'Error creating network.'
      end
    end

    def edit
      render 'admin/networks/form'
    end

    def update
      @network.update(network_params)
      if @network.save
        redirect_to_admin_networks_path('Network was successfully updated.')
      else
        render 'networks/form', alert: 'Error updating network.'
      end
    end

    def destroy
      @network.destroy
      redirect_to_admin_networks_path('Network was successfully deleted.')
    end

    private

    def network_params
      params.require(:network).permit(:name)
    end

    def redirect_to_admin_networks_path(notice)
      redirect_to(
        community_admin_networks_path(current_community),
        notice: notice)
    end
  end
end
