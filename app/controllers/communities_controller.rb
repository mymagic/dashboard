class CommunitiesController < ApplicationController
  # before_action :authenticate_member!
  # load_and_authorize_resource

  def show
  end
  
  def current_community
    @current_community = Community.friendly.find(params[:id])
  end
end
