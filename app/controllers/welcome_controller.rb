class WelcomeController < ApplicationController
  def index
    @current_community = current_member.try(:community)
    redirect_to community_path(@current_community) if @current_community
  end
end
