module Admin
  class CompaniesController < AdminController
    load_and_authorize_resource
    skip_authorize_resource

    def index
      @companies = @companies.ordered
    end

    def new
      @company = Company.new
    end

    def create
      @company = Company.new(company_params)
      respond_to do |format|
        if @company.save
          format.html { redirect_to admin_companies_path, notice: 'Company was successfully created.' }
          format.json { render json: @company, status: :created }
        else
          format.html { render 'new', alert: 'Error creating company.' }
          format.json { render json: @company.errors, status: :unprocessable_entity }
        end
      end
    end

    def edit
    end

    def update
      @company.update(company_params)
      respond_to do |format|
        if @company.save
          format.html { redirect_to admin_companies_path, notice: 'Company was successfully updated.' }
          format.json { render json: @company, status: :created }
        else
          format.html { render 'edit', alert: 'Error updating company.' }
          format.json { render json: @company.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @company.destroy
      respond_to do |format|
        format.html { redirect_to :back, notice: 'Company was successfully deleted.' }
        format.json { head :no_content }
      end
    end

    private

    def company_params
      params.require(:company).permit(
        :name,
        :website,
        :description,
        :logo,
        :logo_cache)
    end
  end
end
