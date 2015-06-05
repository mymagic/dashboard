class SlotsController < ApplicationController
  before_action :authenticate_member!
  load_and_authorize_resource :member
  load_and_authorize_resource :availability
  load_and_authorize_resource through: :availability

  before_action :find_start_time, only: [:create, :destroy]
  before_action :find_end_time, only: [:create, :destroy]

  def create
    if @slot.update(start_time: @start_time, end_time: @end_time, member: current_member)
      redirect_to community_member_availability_path(current_community, @member, @availability),
        notice: 'You have successfully reserved the slot.'
    else
      redirect_to :back, alert: 'Error creating slot.'
    end
  end

  def destroy
    @availability.slots.where(start_time: @start_time, end_time: @end_time).destroy_all

    redirect_to community_member_availability_path(current_community, @member, @availability),
      notice: 'You have successfully released the slot.'
  end

  protected

  def find_start_time
    time = @availability.time
    @start_time = time.change(hour: params[:hour].to_i, min: params[:minute].to_i).to_time
  end

  def find_end_time
    @end_time = @start_time + @availability.slot_duration * 60
  end
end
