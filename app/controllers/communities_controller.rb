class CommunitiesController < ApplicationController
  # before_action :authenticate_member!

  def show
  end

  def edit
  end

  def update
    if @current_community.update_attributes(community_params)
      redirect_to community_path(@current_community)
    else
      respond_with @current_community
    end
  end

  protected

  def current_community
    @current_community = Community.friendly.find(params[:id])
  end

  def community_params
    params.require(:community).permit(:name, :logo)
  end
end
