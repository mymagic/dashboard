class DiscussionsController < ApplicationController
  before_action :authenticate_member!
  load_and_authorize_resource through: :current_community

  def index
  end

  def show
  end

  def new
  end

  def create
  end
end
