class WelcomeController < ApplicationController
  def index
    @current_network = current_member.try(:networks).try(:first)
    if @current_network
      redirect_to [@current_network.community, @current_network]
    end
    @communities = Community.all
  end
end
