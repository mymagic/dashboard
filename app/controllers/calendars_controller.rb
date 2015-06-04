class CalendarsController < ApplicationController
  before_action :authenticate_member!
  load_resource :member
  before_action :find_availabilities, only: :show, if: -> { request.xhr? }
  before_action :find_events, only: :show, if: -> { request.xhr? }

  def show

  end

  protected

  def find_availabilities
    start_date = Date.parse(params[:start])
    end_date = Date.parse(params[:end])

    @availabilities = @member.present? ? @member.availabilities : current_community.availabilities
    @availabilities = @availabilities.group_by_date_with_members(start_date, end_date)
  end

  def find_events
    @events = current_community.events
  end
end
