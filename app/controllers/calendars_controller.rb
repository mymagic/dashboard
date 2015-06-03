class CalendarsController < ApplicationController
  before_action :authenticate_member!

  load_resource :member

  def show
    if request.xhr?
      start_date = Date.parse(params[:start])
      end_date = Date.parse(params[:end])

      @availabilities = @member.present? ? @member.availabilities : current_community.availabilities
      @availabilities = @availabilities.group_by_date_with_members(start_date, end_date)
    end
  end
end
