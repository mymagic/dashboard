class AvailabilitiesController < ApplicationController
  before_action :authenticate_member!

  load_and_authorize_resource :member
  load_and_authorize_resource through: :member
  before_action :find_availability, only: :show
  before_action :find_office_hours, only: :show

  def index
  end

  def new
  end

  def show
    @slots = @availability.virtual_slots
  end

  def create
    if @availability.update(start_time: parse_time('start_time'), end_time: parse_time('end_time'))
      redirect_to community_member_availabilities_path(current_community, @member),
                  notice: 'Availability has successfully created.'
    else
      redirect_to :back, alert: 'Error creating availability.'
    end
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

  def date_params
    "#{params[:month]}-#{params[:day]}-#{params[:year]}"
  end

  def find_availability
    @availability = @member.availabilities
                           .find_by(date: date_params)
  end

  def find_office_hours
    @office_hours = @member.office_hours.by_date(date_params)
  end

  def parse_time(param_name)
    root_params = params[:availability]

    "#{root_params[param_name + '(4i)']}:#{root_params[param_name + '(5i)']}".to_time
  end
end
