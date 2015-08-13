class CompaniesController < ApplicationController
  before_action :authenticate_member!
  load_and_authorize_resource through: :current_network, except: :index

  include UploadConcern
  include FilterConcern
  include CompanyParamsConcern

  def index
    @companies = companies.ordered.page params[:page]
  end

  def show
    founders_and_team_members = @company.founders_and_team_members(network: current_network)
    @founders = founders_and_team_members[:founders]
    @team_members = founders_and_team_members[:team_members]
  end

  def edit
    render 'form'
  end

  def update
    @company.update(company_params)
    if @company.save
      redirect_to(
        community_company_path(current_community, @company),
        notice: 'Company was successfully updated.')
    else
      render 'form', alert: 'Error updating company.'
    end
  end

  private

  def resource_to_upload
    gon.id = @company.id
    @company.logo
  end

  def default_filter
    :portfolio
  end

  def companies
    @companies ||= begin
      ((filter == :portfolio) ? current_network : current_member).companies
    end
  end
end
