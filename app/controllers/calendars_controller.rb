class CalendarsController < ApplicationController
  before_action :authenticate_member!

  def show
    if request.xhr?
      start_date = Date.parse(params[:start])
      end_date = Date.parse(params[:end])

      @office_hours_group = OfficeHour.where(community: current_community)
                                      .group_by_time_with_members(start_date, end_date)
    end
  end
end
