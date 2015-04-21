class CompaniesMembersPositionsController < ApplicationController
  before_action :authenticate_member!
  load_resource :company
  load_and_authorize_resource only: :create

  def index
    authorize! :manage_members_positions, @company
    @approved_companies_members_positions    = @company.companies_members_positions.approved
    @pending_companies_members_positions  = @company.companies_members_positions.pending
  end

  def create
    respond_to do |format|
      if @companies_members_position.update_attributes(
        companies_members_position_params.merge(company: @company))
        
        send_approval_request_notification_email

        format.html do
          redirect_to(
            community_company_url(
              current_member.community,
              @companies_members_position.company),
            notice: 'Position was successfully created '\
                    'but needs to be approved.')
        end
        format.json do
          render json: @companies_members_position, status: :created
        end
      else
        format.html do
          redirect_to(
            community_company_url(current_member.community, @company),
            alert: 'Error creating position.')
        end
        format.json do
          render(
            json: @companies_members_position.errors,
            status: :unprocessable_entity)
        end
      end
    end
  end

  def destroy
    @companies_members_position.destroy
    redirect_to community_company_url(current_member.community, @companies_members_position.company)
  end

  private

  def companies_members_position_params
    params.require(:companies_members_position).permit(:position_id)
  end

  def send_approval_request_notification_email
    company = @companies_members_position.company
    position = @companies_members_position.position

    company.managing_members.each do |recipient|
      CompaniesMembersPositionMailer.send_approval_request_notification(
        current_member, recipient, company, position
      ).deliver_now
    end
  end
end
