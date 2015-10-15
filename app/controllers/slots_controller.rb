class SlotsController < ApplicationController
  before_action :authenticate_member!
  load_and_authorize_resource :member
  load_and_authorize_resource :availability
  load_and_authorize_resource through: :availability

  def create
    if @slot.
       update(start_time: start_time,
              end_time: end_time,
              member: current_member,
              network: current_network)
      redirect_to_availabilty_path('You have successfully reserved the slot.')
    else
      redirect_to :back, alert: 'Error creating slot.'
    end
  end

  def destroy
    @availability.
      slots.
      where(start_time: start_time, end_time: end_time).
      destroy_all

    redirect_to_availabilty_path('You have successfully released the slot.')
  end

  protected

  def start_time
    @start_time ||= @availability.
                    time.
                    change(hour: params[:hour].to_i, min: params[:minute].to_i).
                    to_time
  end

  def end_time
    @end_time ||= start_time + @availability.slot_duration * 60
  end

  def redirect_to_availabilty_path(notice)
    redirect_to(
      community_network_member_availability_slots_path(
        current_community,
        current_network,
        @member,
        year: @availability.date.year,
        month: @availability.date.month,
        day: @availability.date.day),
      notice: notice)
  end
end
