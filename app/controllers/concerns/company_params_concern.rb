module CompanyParamsConcern
  extend ActiveSupport::Concern

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
end
