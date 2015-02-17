class MembersController < ApplicationController
  before_action :authenticate_member!
  load_and_authorize_resource

  def index
  end

  def show
  end
end
