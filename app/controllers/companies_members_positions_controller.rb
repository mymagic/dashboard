class CompaniesMembersPositionsController < ApplicationController
  before_action :authenticate_member!
  load_and_authorize_resource

  def new
    @companies_members_position = CompaniesMembersPosition.new(member: current_member)
  end

  def create
    @companies_members_position = CompaniesMembersPosition.new(companies_members_position_params)
    respond_to do |format|
      if @companies_members_position.save
        format.html { redirect_to @companies_members_position.company, notice: 'Position was successfully created but needs to be approved.' }
        format.json { render json: @companies_members_position, status: :created }
      else
        format.html { render 'new', alert: 'Error creating position.' }
        format.json { render json: @companies_members_position.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def companies_members_position_params
    params.require(:companies_members_position).permit(
      :company_id,
      :member_id,
      :position_id)
  end
end
