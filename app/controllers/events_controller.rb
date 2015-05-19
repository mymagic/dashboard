class EventsController < ApplicationController
  before_action :authenticate_member!
  load_resource through: :current_community

  def show
  end
end
