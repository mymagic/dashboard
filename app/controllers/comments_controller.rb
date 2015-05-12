class CommentsController < ApplicationController
  before_action :authenticate_member!
  load_and_authorize_resource :discussion, through: :current_community
  load_and_authorize_resource :comment, through: :discussion

  def create
    respond_to do |format|
      if @comment.update_attributes(
        comment_params.merge(author: current_member, discussion: @discussion))
        format.html do
          redirect_to([@discussion.community, @discussion],
                      notice: 'Comment was successfully created.')
        end
        format.json { render json: @comment, status: :created }
      else
        format.html { redirect_to :back, alert: 'Error creating comment.' }
        format.json do
          render json: @comment.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @comment.destroy
    respond_to do |format|
      format.html do
        redirect_to([@discussion.community, @discussion],
                    notice: 'Comment was successfully deleted.')
      end
      format.json { head :no_content }
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end
end
