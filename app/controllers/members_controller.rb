class MembersController < ApplicationController
  before_action :authenticate_member!
  load_and_authorize_resource through: :current_community

  def index
    @members = @members.active.ordered
  end

  def show
  end
end
