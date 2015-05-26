class OfficeHoursController < ApplicationController
  before_action :authenticate_member!
  load_resource :member
  load_and_authorize_resource through: :current_community

  before_action :filter_office_hours, only: :index

  def index
    @office_hours = @office_hours.ordered
  end

  def new

  end

  def create
    respond_to do |format|
      if @office_hour.update_attributes(office_hour_params.merge(member: @member, role: 'mentor'))
        format.html { redirect_to community_member_office_hours_path, notice: 'Office Hour was successfully created.' }
        format.json { render json: @office_hour, status: :created }
      else
        format.html { redirect_to :back, alert: 'Error creating office hour.' }
        format.json { render json: @office_hour.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @office_hour.destroy
    respond_to do |format|
      format.html { redirect_to :back, notice: 'Office Hour was successfully deleted.' }
      format.json { head :no_content }
    end
  end

  def book
    @office_hour.participant = current_member
    respond_to do |format|
      if @office_hour.save
        format.html { redirect_to :back, notice: 'Office Hour was successfully booked.' }
        format.json { render json: @office_hour, status: :created }
      else
        format.html { redirect_to :back, alert: 'Error booking office hour.' }
        format.json { render json: @office_hour.errors, status: :unprocessable_entity }
      end
    end
  end

  def cancel
    @office_hour.participant = nil
    respond_to do |format|
      if @office_hour.save
        format.html { redirect_to :back, notice: 'Booking was successfully cancelled.' }
        format.json { render json: @office_hour, status: :created }
      else
        format.html { redirect_to :back, alert: 'Error booking office hour.' }
        format.json { render json: @office_hour.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def office_hour_params
    params.require(:office_hour).permit(
      :time_zone,
      :"time(1i)",
      :"time(2i)",
      :"time(3i)",
      :"time(4i)",
      :"time(5i)")
  end

  def filter_office_hours
    @office_hours = @office_hours.by_date(params[:date]) if params[:date]
  end
end
