module Admin
  class EventsController < AdminController
    load_and_authorize_resource through: :current_community

    def create
      respond_to do |format|
        if @event.update_attributes(event_params)
          format.html do
            redirect_to(community_admin_events_path(current_community),
                        notice: 'Event was successfully created.')
          end
          format.json { render json: @event, status: :created }
        else
          format.html { render 'new', alert: 'Error creating event.' }
          format.json do
            render json: @event.errors, status: :unprocessable_entity
          end
        end
      end
    end

    def new
      @event.assign_attributes(time_zone: current_member.time_zone)
    end

    def index
      @upcoming_events = @events.upcoming
      @past_events     = @events.past
    end

    def update
      @event.update(event_params)
      respond_to do |format|
        if @event.save
          format.html do
            redirect_to(community_admin_events_path(current_community),
                        notice: 'Event was successfully updated.')
          end
          format.json { render json: @event, status: :created }
        else
          format.html { render 'edit', alert: 'Error updating event.' }
          format.json do
            render json: @event.errors, status: :unprocessable_entity
          end
        end
      end
    end

    def edit
    end

    def destroy
      @event.destroy
      respond_to do |format|
        format.html do
          redirect_to(community_admin_events_path(current_community),
                      notice: 'Event was successfully deleted.')
        end
        format.json { head :no_content }
      end
    end

    private

    def event_params
      params.require(:event).permit(
        :title,
        :location_detail,
        :location_type,
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
