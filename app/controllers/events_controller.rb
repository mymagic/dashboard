class EventsController < ApplicationController
  before_action :authenticate_member!
  load_resource through: :current_community

  def show
    @rsvp = @event.rsvps.find_by(member: current_member)
  end

  def rsvp
    @rsvp = @event.rsvps.find_or_initialize_by(member: current_member)
    respond_to do |format|
      if @rsvp.update_attributes(rsvp_params)
        format.html do
          redirect_to(
            community_event_path(current_community, @event),
            notice: "You RSVP'd to the event as "\
                    "#{ rsvp_params[:state].humanize(capitalize: false) }.")
        end
        format.json { render json: @rsvp, status: :created }
      else
        format.html do
          redirect_to(community_event_path(current_community, @event),
                      alert: 'Error creating your RSVP.')
        end
        format.json do
          render json: @rsvp.errors, status: :unprocessable_entity
        end
      end
    end
  end

  private

  def rsvp_params
    params.require(:rsvp).permit(:state)
  end
end
