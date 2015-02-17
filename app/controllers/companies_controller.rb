class CompaniesController < ApplicationController
  before_action :authenticate_member!
  load_and_authorize_resource

  def index
    @companies = @companies.ordered
  end

  def show
  end
end
