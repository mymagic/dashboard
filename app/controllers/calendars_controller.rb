class CalendarsController < ApplicationController
  before_action :authenticate_member!

  def show
    if request.xhr?
      start_date = Date.parse(params[:start])
      end_date = Date.parse(params[:end])

      @availabilities = current_community.availabilities
        .group_by_date_with_members(start_date, end_date)
    end
  end
end
