module Admin
  class CompaniesMembersPositionsController < AdminController
    load_and_authorize_resource through: :current_community

    before_action :find_position, only: [:approve, :reject]
    before_action :find_company, only: [:approve, :reject]

    def index
      @approved_companies_members_positions    = @companies_members_positions.approved
      @pending_companies_members_positions  = @companies_members_positions.pending
    end

    def approve
      if @companies_members_position.update(approver: current_member)
        flash[:notice] = 'Position was successfully approved.'
        CompaniesMembersPositionMailer.send_approve_notification(current_member, @company, @position).deliver_now
      else
        flash[:alert] = 'Error approving position.'
      end

      redirect_to community_admin_companies_members_positions_path
    end

    def reject
      @position.destroy
      CompaniesMembersPositionMailer.send_reject_notification(current_member, @company, @position).deliver_now
      redirect_to community_admin_companies_members_positions_path, notice: 'Position was successfully rejected.'
    end

    protected

    def find_position
      @position ||= @companies_members_position.position
    end

    def find_company
      @company ||= @companies_members_position.company
    end
  end
end
