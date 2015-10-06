class CommunitiesController < ApplicationController
  load_and_authorize_resource find_by: :slug

  include FilterConcern

  def show
    if current_member
      redirect_to [@community, current_member.default_network]
    else
      redirect_if_not_authenticated!
    end
  end

  protected

  def redirect_if_not_authenticated!
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
end
