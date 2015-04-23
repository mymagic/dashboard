module CompaniesMembersPositionsConcern
  extend ActiveSupport::Concern

  included do
    load_resource :company
    before_action :find_position, only: [:approve, :reject]
    before_action :find_company, only: [:approve, :reject, :edit]
  end

  def edit
  end

  def update
    if @companies_members_position.update(update_params)
      flash[:notice] = 'Companies Members Position was successfully updated.'
    else
      flash[:alert] = 'Error approving position.'
    end

    if admin_layout?
      redirect_to community_admin_companies_members_positions_path
    else
      redirect_to community_company_companies_members_positions_path
    end
  end

  def approve
    if @companies_members_position.update(approver: current_member)
      CompaniesMembersPositionMailer.send_approve_notification(
        current_member,
        @company,
        @position).deliver_now
      redirect_to :back, notice: 'Position was successfully approved.'
    else
      redirect_to :back, alert: 'Error approving position.'
    end
  end

  def reject
    @companies_members_position.destroy
    CompaniesMembersPositionMailer.send_reject_notification(
      current_member,
      @company,
      @position).deliver_now
    redirect_to :back, notice: 'Position was successfully rejected.'
  end

  def destroy
    @companies_members_position.destroy
    redirect_to :back, notice: 'Members position has been removed.'
  end

  protected

  def update_params
    params.require(:companies_members_position)
          .permit(:position_id, :can_manage_company)
  end

  def admin_layout?
    self.class.parent == Admin
  end

  def find_position
    @position ||= @companies_members_position.position
  end

  def find_company
    @company ||= @companies_members_position.company
  end
end
