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
      if @discussion.
         update_attributes(discussion_params.merge(author: current_member))
        format.html do
          redirect_to([@discussion.community, @discussion],
                      notice: 'Discussion was successfully created.')
        end
        format.json { render json: @discussion, status: :created }
      else
        format.html { redirect_to :back, alert: 'Error creating discussion.' }
        format.json do
          render json: @discussion.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def follow
    @discussion.followers << current_member
    redirect_to :back, notice: 'You are now following the discussion.'
  end

  def unfollow
    @discussion.followers.delete(current_member)
    redirect_to :back, notice: 'You stopped following the discussion.'
  end

  private

  def discussion_params
    params.require(:discussion).permit(:title, :body)
  end
end
