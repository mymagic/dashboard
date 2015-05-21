class AvailabilitiesController < ApplicationController
  before_action :authenticate_member!

  load_and_authorize_resource :member
  load_and_authorize_resource :availability, through: :member

  def new
  end

  def create
    if @availability.update(start_time: parse_time('start_time'), end_time: parse_time('end_time'))
      redirect_to community_member_availabilities_path(current_community, @member),
                  notice: 'Availability has successfully created.'
    else
      redirect_to :back, alert: 'Error creating availability.'
    end
  end

  def index
  end

  def destroy
    @availability.destroy

    redirect_to community_member_availabilities_path(current_community, @member),
                notice: 'Availability has successfully deleted.'
  end

  protected

  def availability_params
    params.require(:availability)
          .permit(
            :date,
            :slot_duration,
            :time_zone,
            :recurring,
            :location_type,
            :location_detail,
            :details
          )
  end

  def parse_time(param_name)
    root_params = params[:availability]

    "#{root_params[param_name + '(4i)']}:#{root_params[param_name + '(5i)']}".to_time
  end
end
