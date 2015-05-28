class SlotsController < ApplicationController
  before_action :authenticate_member!
  load_resource :member
  load_resource :availability

  def create
    time       = @availability.time
    start_time = time.change(hour: params[:hour].to_i, min: params[:minute].to_i).to_time
    end_time   = start_time + @availability.slot_duration * 60

    @availability.slots.create(start_time: start_time, end_time: end_time)
    redirect_to community_member_availability_slots_path(current_community, @member, *@availability.date.strftime.split('-')),
      notice: 'Slot has already been reserved.'
  end
end
