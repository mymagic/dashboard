module Admin
  class MembersController < AdminController
    load_and_authorize_resource
    before_action :allow_without_password, only: :update

    def index
      @invited_members    = @members.invited.ordered
      @active_members     = @members.active.ordered
    end

    def new
      @member = Member.new(time_zone: current_member.time_zone)
      @member.companies_positions.build(approved: true)
    end

    def create
      @member = invite_member
      member_invited = @member.errors.empty?

      respond_to do |format|
        if member_invited
          format.html { redirect_to community_admin_members_path(@current_community), notice: 'Member was successfully invited.' }
          format.json { render json: @member, status: :created }
        else
          @member.companies_positions.build(approved: true)
          format.html { render 'new', alert: 'Error inviting member.' }
          format.json { render json: @member.errors, status: :unprocessable_entity }
        end
      end
    end

    def edit
      @member.companies_positions.build(approved: true)
    end

    def update
      @member.update(member_params)
      respond_to do |format|
        if @member.save
          format.html { redirect_to community_admin_members_path(@current_community), notice: 'Member was successfully updated.' }
          format.json { render json: @member, status: :created }
        else
          format.html { render 'edit', alert: 'Error updating member.' }
          format.json { render json: @member.errors, status: :unprocessable_entity }
        end
      end
    end

    def resend_invitation
      Member.invite!({ email: @member.email }, current_member)
      respond_to do |format|
        format.html { redirect_to community_admin_members_path(@current_community), notice: 'Member invitation was resend.' }
        format.json { render json: @member, status: :created }
      end
    end

    def destroy
      @member.destroy
      respond_to do |format|
        format.html { redirect_to community_admin_members_path(@current_community), notice: 'Member was successfully deleted.' }
        format.json { head :no_content }
      end
    end

    private

    def allow_without_password
      if params[:member][:password].blank? && params[:member][:password_confirmation].blank?
        params[:member].delete("password")
        params[:member].delete("password_confirmation")
      end
    end

    def member_params
      permitted = params.require(:member).permit(
        :first_name,
        :last_name,
        :email,
        :password,
        :password_confirmation,
        :time_zone,
        :role,
        :avatar,
        :avatar_cache,
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
      raise CanCan::AccessDenied unless current_member.can_assign_role? permitted[:role]
      permitted
    end

    def invite_member(&block)
      Member.invite!(member_params.merge(community_id: current_community.id), current_member, &block)
    end
  end
end
