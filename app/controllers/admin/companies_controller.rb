module Admin
  class CompaniesController < AdminController
    load_and_authorize_resource through: :current_community
    before_action :set_javascript_variables, only: [:edit, :update]

    include CompanyParamsConcern

    def index
      @companies = @companies.ordered
    end

    def new
      render 'companies/form'
    end

    def create
      if @company.save
        redirect_to_admin_companies_path('Company was successfully created.')
      else
        render 'companies/form', alert: 'Error creating company.'
      end
    end

    def edit
      render 'companies/form'
    end

    def update
      @company.update(company_params)
      if @company.save
        redirect_to_admin_companies_path('Company was successfully updated.')
      else
        render 'companies/form', alert: 'Error updating company.'
      end
    end

    def destroy
      @company.destroy
      redirect_to_admin_companies_path('Company was successfully deleted.')
    end

    private

    def set_javascript_variables
      s3_direct_upload_data = @company.logo.s3_direct_upload_data
      gon.directUploadUrl = s3_direct_upload_data.url
      gon.directUploadFormData = s3_direct_upload_data.fields
      gon.model = "company"
      gon.id = @company.id
    end

    def redirect_to_admin_companies_path(notice)
      redirect_to(
        community_admin_companies_path(current_community),
        notice: notice)
    end
  end
end
