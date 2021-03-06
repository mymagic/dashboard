class CommentsController < ApplicationController
  before_action :authenticate_member!
  load_and_authorize_resource :discussion, through: :current_network
  load_and_authorize_resource :comment, through: :discussion

  def create
    @comment.author = current_member
    if @comment.save
      redirect_to([@discussion.community, @discussion.network, @discussion],
                  notice: 'Comment was successfully created.')
    else
      redirect_to :back, alert: 'Error creating comment.'
    end
  end

  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.html do
          redirect_to([@discussion.community, @discussion.network, @discussion],
                      notice: 'Comment was successfully created.')
        end
        format.json { respond_with_bip(@comment) }
      else
        format.html { redirect_to :back, alert: 'Error creating comment.' }
        format.json { respond_with_bip(@comment) }
      end
    end
  end

  def destroy
    @comment.destroy
    respond_to do |format|
      format.html do
        redirect_to([@discussion.community, @discussion.network, @discussion],
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
