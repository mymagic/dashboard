module Admin
  class MembersController < AdminController
    load_and_authorize_resource

    def index
    end
  end
end
