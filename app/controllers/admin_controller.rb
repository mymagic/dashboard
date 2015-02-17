class AdminController < ApplicationController
  before_action :authenticate_member!
  before_action :authorize_administration!

  def dashboard
  end

  protected

  def authorize_administration!
    authorize! :administrate, :application
  end
end
