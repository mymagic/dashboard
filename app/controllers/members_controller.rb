class MembersController < ApplicationController
  before_action :authenticate_member!
  load_resource :company
  load_resource through: :current_community
  skip_authorize_resource only: [:new, :create]

  include MembersConcern

  def index
    @members = @members.active.ordered
  end

  def show
  end

  def new
    @member = Member.new(time_zone: current_member.time_zone)
    @member.companies_positions.build(approver: current_member, company: @company)
    authorize! :create, @member
  end

  def create
    authorize! :create, @member
    @member = invite_member
    if @member.errors.empty?
      redirect_to community_company_path(@company.community, @company), notice: 'Member was successfully invited.'
    else
      @member.companies_positions.build(approver: current_member, company: @company) unless @member.companies_positions.any?
      render 'new', alert: 'Error inviting member.'
    end
  rescue CompaniesMembersPosition::AlreadyExistsError => exception
    redirect_to(
      new_community_company_member_path(@company.community, @company),
      warning: exception.message
    )
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
          :company_id,
          :position_id,
          :can_manage_company,
          :_destroy,
          :id
        ]
    )
  end

  def existing_member
    @existing_member ||= current_community.members.find_by(
      email: member_params[:email])
  end

  def add_position_to_existing_member
    existing_member.update(member_params.slice(:companies_positions_attributes))
    existing_member
  rescue ActiveRecord::RecordNotUnique
    raise CompaniesMembersPosition::AlreadyExistsError
  end

  def invite_member(&block)
    return add_position_to_existing_member if existing_member
    Member.invite!(member_create_params, current_member, &block)
  end
end
