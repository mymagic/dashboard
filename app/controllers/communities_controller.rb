class CommunitiesController < ApplicationController
  skip_before_action :authorize_community!, except: [:show, :index]
  before_action :authorize_community, except: [:show, :index]

  def show
  end

  def edit
  end

  def update
    if @current_community.update_attributes(community_params)
      redirect_to community_path(@current_community), notice: 'Community was successfully invited.'
    else
      respond_with @current_community
    end
  end

  protected

  def current_community
    @current_community = Community.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise Community::CommunityNotFound
  end

  def authorize_community
    authorize! :manage, current_community
  end

  def community_params
    params.require(:community).permit(:name, :logo, :email, :social_media_services)
  end
end
