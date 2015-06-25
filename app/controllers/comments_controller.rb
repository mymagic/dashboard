class CommentsController < ApplicationController
  before_action :authenticate_member!
  load_and_authorize_resource :discussion, through: :current_community
  load_and_authorize_resource :comment, through: :discussion

  def create
    @comment.author = current_member
    if @comment.save
      redirect_to([@discussion.community, @discussion],
                  notice: 'Comment was successfully created.')
    else
      redirect_to :back, alert: 'Error creating comment.'
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
