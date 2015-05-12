class DiscussionsController < ApplicationController
  before_action :authenticate_member!
  load_and_authorize_resource through: :current_community

  include TagsConcern

  def index
    @discussions = @discussions.tagged_with(tag) if tag
    @discussions = @discussions.filter_by(current_filter).page params[:page]
  end

  def show
    @comment = @discussion.comments.build
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
        format.html { render 'new', alert: 'Error creating discussion.' }
        format.json do
          render json: @discussion.errors, status: :unprocessable_entity
        end
      end
    end
  end

  def destroy
    @discussion.destroy
    respond_to do |format|
      format.html do
        redirect_to(
          community_discussions_path(current_community),
          notice: 'Discussion was successfully deleted.')
      end
      format.json { head :no_content }
    end
  end

  def follow
    if @discussion.followers.include? current_member
      redirect_to :back, warning: 'You are already following the discussion.'
    else
      @discussion.followers << current_member
      redirect_to :back, notice: 'You are now following the discussion.'
    end
  end

  def unfollow
    @discussion.followers.delete(current_member)
    redirect_to :back, notice: 'You stopped following the discussion.'
  end

  private

  def current_filter
    @current_filter ||= (params[:filter_by] || 'recent').to_sym
  end

  def discussion_params
    params.require(:discussion).permit(:title, :body, :tag_list)
  end
end
