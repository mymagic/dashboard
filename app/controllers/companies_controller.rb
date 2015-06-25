class CompaniesController < ApplicationController
  before_action :authenticate_member!
  load_and_authorize_resource through: :current_community, except: :index
  before_action :set_javascript_variables, only: [:edit, :update]

  include FilterConcern
  include CompanyParamsConcern

  def index
    @companies = companies.ordered.page params[:page]
  end

  def show
    founders_and_team_members = @company.founders_and_team_members
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

  def set_javascript_variables
    s3_direct_upload_data = @company.logo.s3_direct_upload_data
    gon.directUploadUrl = s3_direct_upload_data.url
    gon.directUploadFormData = s3_direct_upload_data.fields
    gon.model = "company"
    gon.id = @company.id
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
