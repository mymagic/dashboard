class WelcomeController < ApplicationController
  def index
    @current_network = current_member.networks.try(:first)
    redirect_to community_network_path(@current_network.community, @current_network) if @current_community
    @network = Network.all
  end
end
