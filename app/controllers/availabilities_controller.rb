class AvailabilitiesController < ApplicationController
  before_action :authenticate_member!

  load_and_authorize_resource :member
  load_and_authorize_resource(
    through: [:member, :current_community], except: [:calendar, :slots])

  def index
  end

  def calendar
    @members = @member ? [@member] : Member.by_availability_date(date)
    @date = date
  end

  def slots
    @availabilities = @member.availabilities.by_date(date)
  end

  def new
    @availability.time_zone = current_member.time_zone
  end

  def edit
  end

  def update
    update_availability
    @availability.slots.destroy_all

    redirect_to community_member_availabilities_path(current_community, @member),
                notice: 'Availability was successfully updated.'
  end

  def create
    if update_availability
      redirect_to community_member_availabilities_path(current_community, @member),
                  notice: 'Availability was successfully created.'
    else
      render 'new', alert: 'Error creating availability.'
    end
  end

  def destroy
    @availability.destroy

    redirect_to community_member_availabilities_path(current_community, @member),
                notice: 'Availability was successfully deleted.'
  end

  protected

  def availability_params
    params.require(:availability)
          .permit(
            :slot_duration,
            :time_zone,
            :recurring,
            :location_type,
            :location_detail,
            :details
          )
  end

  def date
    if params[:year].nil? || params[:month].nil? || params[:day].nil?
      redirect_to(
        community_member_path(current_community, @member),
        alert: 'Invalid date.')
    else
      @date = Date.parse("#{params[:year]}-#{params[:month]}-#{params[:day]}")
    end
  end

  def parse_time(param_name)
    root_params = params[:availability]
    time_zone   = root_params[:time_zone]

    time = "#{root_params[param_name + '(4i)']}:#{root_params[param_name + '(5i)']}".to_time

    ActiveSupport::TimeZone.new(time_zone)
                           .local_to_utc(time)
                           .in_time_zone(time_zone)
  end

  def update_availability
    # Seems like cancancan does not auto update :date params
    availability_params = params[:availability]

    @availability.update(
      start_time: parse_time('start_time'),
      end_time: parse_time('end_time'),
      date: "#{availability_params['date(1i)']}-#{availability_params['date(2i)']}-#{availability_params['date(3i)']}"
    )
  end
end
