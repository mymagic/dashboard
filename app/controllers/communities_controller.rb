class CommunitiesController < ApplicationController
  before_action :authorize_through_magic_connect!
  before_action :redirect_if_not_authenticated!
  load_and_authorize_resource find_by: :slug

  include FilterConcern

  def show
    redirect_to [@community, @community.networks.first]
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

end
