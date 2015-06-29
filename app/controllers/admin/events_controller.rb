module Admin
  class EventsController < AdminController
    load_and_authorize_resource through: :current_community

    def create
      if @event.save
        redirect_to_admin_events_path('Event was successfully created.')
      else
        render 'new', alert: 'Error creating event.'
      end
    end

    def new
      @event.assign_attributes(time_zone: current_member.time_zone)
    end

    def index
      @upcoming_events = @events.upcoming.ordered.page params[:page]
      @past_events     = @events.past.ordered
    end

    def update
      @event.update(event_params)
      if @event.save
        redirect_to_admin_events_path('Event was successfully updated.')
      else
        render 'edit', alert: 'Error updating event.'
      end
    end

    def edit
    end

    def destroy
      @event.destroy
      redirect_to_admin_events_path('Event was successfully deleted.')
    end

    private

    def redirect_to_admin_events_path(notice)
      redirect_to(
        community_admin_events_path(current_community), notice: notice)
    end

    def event_params
      params.require(:event).permit(
        :title,
        :location_detail,
        :location_type,
        :location_longitude,
        :location_latitude,
        :location_zoom,
        :description,
        :time_zone,
        :external,
        :"starts_at(1i)",
        :"starts_at(2i)",
        :"starts_at(3i)",
        :"starts_at(4i)",
        :"starts_at(5i)",
        :"ends_at(1i)",
        :"ends_at(2i)",
        :"ends_at(3i)",
        :"ends_at(4i)",
        :"ends_at(5i)").merge(creator: current_member)
    end
  end
end
