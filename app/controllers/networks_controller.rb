class NetworksController < ApplicationController
  # layout :false
  before_action :set_current_network
  before_action :set_activities

  include FilterConcern

  def show
    authorize! :read, current_network
    @events = current_network.events.upcoming.ordered
    @availabilities = current_network.availabilities_for_show
  end

  protected

  def default_filter
    :public
  end

  def community
    @current_network.community
  end

  def set_activities
    @activities = begin
      if filter == :personal
        activities = @current_network.activities
        activities.for(current_member).includes(:owner).ordered.limit(20)
      else
        @current_network.activities_for_show
      end
    end
  end

  def set_current_network
    @current_network ||= Network.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to member.default_network
  end
end
