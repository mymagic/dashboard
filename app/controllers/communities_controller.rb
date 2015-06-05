class CommunitiesController < ApplicationController
  before_action :redirect_if_not_authenticated!
  load_and_authorize_resource find_by: :slug
  before_action :activities

  include FilterConcern

  def show
    @activities = @activities.includes(:owner).ordered.limit(20)
  end

  protected

  def redirect_if_not_authenticated!
    return if member_signed_in?
    redirect_to(
      new_member_session_path(current_community),
      alert: t('devise.failure.unauthenticated')
    )
  end

  def current_community
    @current_community ||= Community.friendly.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    raise Community::CommunityNotFound
  end

  def default_filter
    :public
  end

  def activities
    @activities = begin
      if filter == :personal
        @community.activities.for(current_member)
      else
        @community.activities
      end
    end
  end
end
