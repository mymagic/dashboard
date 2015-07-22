class EventsController < ApplicationController
  before_action :authenticate_member!
  load_resource through: :current_community

  def show
    @rsvp = @event.rsvps.find_by(member: current_member)
  end

  def rsvp
    @rsvp = @event.rsvps.find_or_initialize_by(member: current_member)
    if @rsvp.update_attributes(rsvp_params)
      redirect_to(
        [@event.network.community, @event.network, @event],
        notice: "You RSVP'd to the event as #{ @rsvp }.")
    else
      redirect_to(
        [@event.network.community, @event.network, @event],
        alert: 'Error creating your RSVP.')
    end
  end

  private

  def rsvp_params
    params.require(:rsvp).permit(:state)
  end
end
