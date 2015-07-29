module Admin
  class CompaniesController < AdminController
    load_and_authorize_resource through: :current_community

    include UploadConcern
    include CompanyParamsConcern

    def index
      @companies = @companies.ordered.page params[:page]
    end

    def new
      render 'companies/form'
    end

    def create
      if @company.save
        redirect_to(
          edit_community_admin_company_path(current_community, @company),
          notice: 'Company was successfully created.')
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

    def resource_to_upload
      gon.id = @company.id
      @company.logo
    end

    def redirect_to_admin_companies_path(notice)
      redirect_to(
        community_admin_companies_path(current_community),
        notice: notice)
    end
  end
end
