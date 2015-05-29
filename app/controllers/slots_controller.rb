class SlotsController < ApplicationController
  before_action :authenticate_member!
  load_and_authorize_resource :member
  load_and_authorize_resource :availability
  load_and_authorize_resource through: :availability

  def create
    time       = @availability.time
    start_time = time.change(hour: params[:hour].to_i, min: params[:minute].to_i).to_time
    end_time   = start_time + @availability.slot_duration * 60

    if @slot.update(start_time: start_time, end_time: end_time)
      redirect_to community_member_availability_path(current_community, @member, @availability),
        notice: 'Slot has already been reserved.'
    else
      redirect_to :back, alert: 'Error creating slot.'
    end
  end
end
