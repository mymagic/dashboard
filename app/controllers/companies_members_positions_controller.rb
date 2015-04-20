class CompaniesMembersPositionsController < ApplicationController
  before_action :authenticate_member!
  load_and_authorize_resource

  def create
    respond_to do |format|
      if @companies_members_position.update_attributes(companies_members_position_params)
        send_position_change_email

        format.html do
          redirect_to(
            community_company_url(current_member.community, @companies_members_position.company),
            notice: 'Position was successfully created but needs to be approved.')
        end
        format.json { render json: @companies_members_position, status: :created }
      else
        format.html do
          redirect_to(
            community_company_url(current_member.community, @companies_members_position.company),
            alert: 'Error creating position.')
        end
        format.json { render json: @companies_members_position.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @companies_members_position.destroy
    redirect_to community_company_url(current_member.community, @companies_members_position.company)
  end

  private

  def companies_members_position_params
    params.require(:companies_members_position).permit(
      :company_id,
      :position_id)
  end

  def send_position_change_email
    company = @companies_members_position.company
    position = @companies_members_position.position

    company.permitted_members.each do |recipient|
      PositionMailer.send_position_change(
        current_member, recipient, company, position
      ).deliver_now
    end
  end
end
