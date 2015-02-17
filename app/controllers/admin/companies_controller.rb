module Admin
  class CompaniesController < AdminController
    load_and_authorize_resource

    def index
    end
  end
end
