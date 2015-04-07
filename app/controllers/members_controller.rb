class MembersController < ApplicationController
  before_action :authenticate_member!
  load_resource :company
  load_resource through: :current_community
  skip_authorize_resource only: [:new, :create]

  def index
    @members = @members.active.ordered
  end

  def show
  end

  def new
    @member = Member.new(time_zone: current_member.time_zone)
    @member.companies_positions.build(approved: true, company: @company)
    @member.social_media_links.build
    authorize! :create, @member
  end

  def create
    authorize! :create, @member
    @member = invite_member
    member_invited = @member.errors.empty?

    respond_to do |format|
      if member_invited
        format.html { redirect_to community_company_path(@company.community, @company), notice: 'Member was successfully invited.' }
        format.json { render json: @member, status: :created }
      else
        @member.companies_positions.build(approved: true, company: @company) unless @member.companies_positions.any?
        format.html { render 'new', alert: 'Error inviting member.' }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def member_params
    params.require(:member).permit(
      :first_name,
      :last_name,
      :email,
      :time_zone,
      companies_positions_attributes:
        [
          :approved,
          :company_id,
          :position_id,
          :can_manage_company,
          :_destroy,
          :id
        ]
    )
  end

  def invite_member(&block)
    Member.invite!(member_params.merge(community_id: current_community.id), current_member, &block)
  end
end
