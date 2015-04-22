module CompaniesMembersPositionsConcern
  extend ActiveSupport::Concern

  included do
    load_resource :company

    before_action :find_position, only: [:approve, :reject]
    before_action :find_company, only: [:approve, :reject]
  end

  def approve
    if @companies_members_position.update(approver: current_member)
      flash[:notice] = 'Position was successfully approved.'
      CompaniesMembersPositionMailer.send_approve_notification(current_member, @company, @position).deliver_now
    else
      flash[:alert] = 'Error approving position.'
    end

    redirect_to [current_community, admin_layout_presence, @companies_members_position]
  end

  def reject
    @companies_members_position.destroy
    CompaniesMembersPositionMailer.send_reject_notification(current_member, @company, @position).deliver_now

    redirect_to [current_community, admin_layout_presence, @companies_members_position], notice: 'Position was successfully rejected.'
  end

  protected

  def find_position
    @position ||= @companies_members_position.position
  end

  def find_company
    @company ||= @companies_members_position.company
  end

  def admin_layout_presence
    self.class.parent == Admin ? :admin : nil
  end
end
