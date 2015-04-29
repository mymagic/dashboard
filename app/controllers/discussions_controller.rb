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
    respond_to do |format|
      if @discussion.update_attributes(discussion_params.merge(author: current_member))
        format.html { redirect_to [@discussion.community, @discussion], notice: 'Discussion was successfully created.' }
        format.json { render json: @discussion, status: :created }
      else
        format.html { redirect_to :back, alert: 'Error creating discussion.' }
        format.json { render json: @discussion.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def discussion_params
    params.require(:discussion).permit(:title, :body)
  end
end
