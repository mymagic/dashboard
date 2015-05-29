class CommunitiesController < ApplicationController

  def show
  end

  protected

  def current_community
    @current_community ||= Community.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise Community::CommunityNotFound
  end
end
