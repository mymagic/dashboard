class MembersController < ApplicationController
  before_action :authenticate_member!
  load_resource :company
  load_resource through: :current_community
  skip_authorize_resource only: [:new, :create]

  include FilterConcern

  def index
    @members = @members.
               active.
               filter_by(filter).
               uniq.
               ordered.
               page params[:page]
  end

  def show
  end

  def activities
    @activities = @member.activities.ordered.limit(20)
  end

  def new
    @member = Member.new(time_zone: current_member.time_zone)
    @member.positions.build(company: @company)
    authorize! :create, @member
  end

  def create
    authorize! :create, @member
    @member = invite_member
    if @member.errors.empty?
      redirect_to(
        community_company_path(@company.community, @company),
        notice: 'Member was successfully invited.')
    else
      @member.positions.build unless @member.positions.any?
      render 'new', alert: 'Error inviting member.'
    end
  rescue Position::AlreadyExistsError => exception
    redirect_to(
      new_community_company_member_path(@company.community, @company),
      warning: exception.message
    )
  end

  def follow
    if @member.followers.include? current_member
      redirect_to(
        :back, warning: "You are already following #{ @member.full_name }.")
    else
      @member.followers << current_member
      redirect_to :back, notice: "You are now following #{ @member.full_name }."
    end
  end

  def unfollow
    @member.followers.delete(current_member)
    redirect_to :back, notice: "You stopped following #{ @member.full_name }."
  end

  private

  def member_params
    params.require(:member).permit(
      :first_name,
      :last_name,
      :email,
      :time_zone,
      positions_attributes:
        [
          :founder,
          :role,
          :_destroy,
          :id
        ]
    ).tap do |attrs|
      attrs[:community_id] = current_community.id
      attrs[:positions_attributes].map do |key, value|
        param = key.is_a?(Hash) ? key : value
        param[:company_id]  = @company.id
      end if attrs[:positions_attributes]
    end
  end

  def existing_member
    @existing_member ||= current_community.members.find_by(
      email: member_params[:email])
  end

  def add_position_to_existing_member
    existing_member.update(member_params.slice(:positions_attributes))
    existing_member
  rescue ActiveRecord::RecordNotUnique
    raise Position::AlreadyExistsError
  end

  def invite_member(&block)
    return add_position_to_existing_member if existing_member
    Member.invite!(member_params, current_member, &block)
  end

  def default_filter
    :everyone
  end
end
