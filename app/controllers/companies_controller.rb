class CompaniesController < ApplicationController
  before_action :authenticate_member!
  load_and_authorize_resource through: :current_community

  include SocialMediaLinksConcern

  before_action only: [:edit] { social_media_links(@company) }

  def index
    @companies = @companies.ordered
  end

  def show
  end

  def edit
  end

  def update
    @company.update(company_params)
    respond_to do |format|
      if @company.save
        format.html { redirect_to community_company_path(current_community, @company), notice: 'Company was successfully updated.' }
        format.json { render json: @company, status: :created }
      else
        format.html { render 'edit', alert: 'Error updating company.' }
        format.json { render json: @company.errors, status: :unprocessable_entity }
      end
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
      social_media_links_attributes:
        [
          :id,
          :service,
          :handle,
          :_destroy
        ]
    )
  end
end
