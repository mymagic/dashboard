class AvailabilitiesController < ApplicationController
  before_action :authenticate_member!

  load_and_authorize_resource :member
  load_and_authorize_resource through: [:member, :current_community]

  def index
    @availabilities = @availabilities.by_date(date_params).ordered if date_params.present?
  end

  def new
    @availability.time_zone = current_member.time_zone
  end

  def show
    @slots = @availability.virtual_slots
  end

  def edit
  end

  def update
    @availability.slots.destroy_all
    update_availability

    redirect_to community_member_availabilities_path(current_community, @member),
                notice: 'Availability has successfully updated.'
  end

  def create
    if update_availability
      redirect_to community_member_availabilities_path(current_community, @member),
                  notice: 'Availability has successfully created.'
    else
      render 'new', alert: 'Error creating availability.'
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
    return nil if params[:month].nil? || params[:day].nil? || params[:year].nil?

    "#{params[:month]}-#{params[:day]}-#{params[:year]}"
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
    @availability.update(start_time: parse_time('start_time'), end_time: parse_time('end_time'))
  end
end
