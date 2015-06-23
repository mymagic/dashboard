class DiscussionsController < ApplicationController
  before_action :authenticate_member!
  load_and_authorize_resource through: :current_community

  include TagsConcern
  include FilterConcern

  def index
    return member_discussions if params[:member_id]
    @discussions = @discussions.tagged_with(tag) if tag
    @discussions = @discussions.
                   includes(:author, :comments, :followers, :tags).
                   filter_by(filter).
                   page params[:page]
  end

  def show
    @comment = @discussion.comments.build
  end

  def new
  end

  def create
    if @discussion.
       update_attributes(discussion_params.merge(author: current_member))
      redirect_to([@discussion.community, @discussion],
                  notice: 'Discussion was successfully created.')
    else
      render 'new', alert: 'Error creating discussion.'
    end
  end

  def destroy
    @discussion.destroy
    redirect_to(
      community_discussions_path(current_community),
      notice: 'Discussion was successfully deleted.')
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

  def member_discussions
    @member = Member.find(params[:member_id])
    @discussions = @discussions.
                   where(author: @member).
                   filter_by(:recent).
                   limit(10)
    render 'members/discussions'
  end

  def default_filter
    :recent
  end

  def discussion_params
    params.require(:discussion).permit(:title, :body, :tag_list)
  end
end
