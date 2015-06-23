class ActivitiesController < ApplicationController
  before_action :authenticate_member!

  load_and_authorize_resource :member
  load_and_authorize_resource through: :member

  def index
    @activities = @activities.includes(:owner)
    render 'members/activities'
  end
end
