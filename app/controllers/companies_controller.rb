class CompaniesController < ApplicationController
  before_action :authenticate_member!
  load_and_authorize_resource through: :current_community, except: :index

  include FilterConcern

  def index
    @companies = companies.ordered.page params[:page]
  end

  def show
    founders_and_team_members = @company.founders_and_team_members
    @founders = founders_and_team_members[:founders]
    @team_members = founders_and_team_members[:team_members]
  end

  def edit
  end

  def update
    @company.update(company_params)
    if @company.save
      redirect_to(
        community_company_path(current_community, @company),
        notice: 'Company was successfully updated.')
    else
      render 'edit', alert: 'Error updating company.'
    end
  end

  private

  def company_params
    params.require(:company).permit(
      :name,
      :website,
      :description,
      :logo,
      :logo_cache,
      social_media_links_attributes: [:id, :service, :url, :_destroy]
    )
  end

  def default_filter
    :portfolio
  end

  def companies
    @companies ||= begin
      ((filter == :portfolio) ? current_community : current_member).companies
    end
  end
end
