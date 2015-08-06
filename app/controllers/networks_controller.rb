class NetworksController < ApplicationController
  # layout :false
  before_action :authorize_through_magic_connect!
  before_action :set_current_network
  before_action :set_activities

  include FilterConcern

  def show
    @activities = @activities.includes(:owner).ordered.limit(20)
    @events = current_network.events.upcoming.ordered
    @availabilities = current_network.
                      availabilities.
                      joins(:member).
                      by_daterange(Date.today, 1.week.from_now.to_date).
                      ordered
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
        @current_network.activities.for(current_member)
      else
        @current_network.activities
      end
    end
  end

  def set_current_network
    @current_network ||= Network.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to member.default_network
  end

end
