class CompaniesController < ApplicationController
  before_action :authenticate_member!
  load_and_authorize_resource through: :current_community, except: :index
  before_action :load_companies, only: :index

  include SocialMediaLinksConcern

  before_action only: [:edit] { social_media_links(@company) }

  def index
    @companies = @companies.ordered.page params[:page]
  end

  def show
  end

  def edit
  end

  def update
    @company.update(company_params)
    respond_to do |format|
      if @company.save
        format.html do
          redirect_to(
            community_company_path(current_community, @company),
            notice: 'Company was successfully updated.')
        end
        format.json { render json: @company, status: :created }
      else
        format.html { render 'edit', alert: 'Error updating company.' }
        format.json do
          render json: @company.errors, status: :unprocessable_entity
        end
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

  def current_filter
    @current_filter ||= (params[:filter_by] || 'portfolio').to_sym
  end

  def load_companies
    @companies = if current_filter == :mine
                   current_member.companies
                 else
                   current_community.companies
                 end
  end
end
