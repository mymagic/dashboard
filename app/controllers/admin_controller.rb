class AdminController < ApplicationController
  before_action :authenticate_member!
  before_action :authorize_administration!
  before_action :admin_navigation

  protected

  def authorize_administration!
    authorize! :administrate, :application
  end

  def admin_navigation
    @admin_navigation = true
  end
end
