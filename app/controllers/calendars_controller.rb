class CalendarsController < ApplicationController
  before_action :authenticate_member!
  load_resource :member
  before_action :find_availabilities, only: :show
  before_action :find_events, only: :show

  def show
  end

  protected

  def find_availabilities
    return unless request.xhr?

    start_date = Date.parse(params[:start])
    end_date = Date.parse(params[:end])

    @availabilities = @member.present? ? @member.availabilities : current_network.availabilities
    @availabilities = @availabilities.group_by_date_with_members(start_date, end_date)
  end

  def find_events
    return unless request.xhr? && @member.nil?
    @events = current_network.events
  end
end
