class MembersController < ApplicationController
  before_action :authenticate_member!
  load_and_authorize_resource

  def index
    @members = @members.active.ordered
  end

  def show
  end
end
