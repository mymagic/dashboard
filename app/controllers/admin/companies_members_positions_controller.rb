module Admin
  class CompaniesMembersPositionsController < AdminController
    load_and_authorize_resource through: :current_community
    
    include CompaniesMembersPositionsConcern

    def index
      @approved_companies_members_positions    = @companies_members_positions.approved
      @pending_companies_members_positions  = @companies_members_positions.pending
    end
  end
end
