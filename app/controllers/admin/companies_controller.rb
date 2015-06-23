module Admin
  class CompaniesController < AdminController
    load_and_authorize_resource through: :current_community

    include CompanyParamsConcern

    def index
      @companies = @companies.ordered
    end

    def new
    end

    def create
      if @company.update_attributes(company_params)
        redirect_to_admin_companies_path('Company was successfully created.')
      else
        render 'new', alert: 'Error creating company.'
      end
    end

    def edit
    end

    def update
      @company.update(company_params)
      if @company.save
        redirect_to_admin_companies_path('Company was successfully updated.')
      else
        render 'edit', alert: 'Error updating company.'
      end
    end

    def destroy
      @company.destroy
      redirect_to_admin_companies_path('Company was successfully deleted.')
    end

    private

    def redirect_to_admin_companies_path(notice)
      redirect_to(
        community_admin_companies_path(current_community),
        notice: notice)
    end
  end
end
