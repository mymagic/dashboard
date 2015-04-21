module Admin
  class CompaniesMembersPositionsController < AdminController
    load_and_authorize_resource through: :current_community

    def index
      @approved_companies_members_positions    = @companies_members_positions.approved
      @unapproved_companies_members_positions  = @companies_members_positions.unapproved
    end
  end
end
