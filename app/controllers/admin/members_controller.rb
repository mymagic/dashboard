module Admin
  class MembersController < AdminController
    load_and_authorize_resource through: :current_community
    before_action :allow_without_password, only: :update

    def index
      @invited_members    = @members.invited.ordered
      @active_members     = @members.active.ordered
    end

    def new
      @member.time_zone = current_member.time_zone
      @member.positions.build
    end

    def create
      @member = invite_member
      member_invited = @member.errors.empty?

      respond_to do |format|
        if member_invited
          format.html do
            redirect_to(
              community_admin_members_path(current_community),
              notice: 'Member was successfully invited.')
          end
          format.json { render json: @member, status: :created }
        else
          @member.positions.build
          format.html { render 'new', alert: 'Error inviting member.' }
          format.json do
            render json: @member.errors, status: :unprocessable_entity
          end
        end
      end
    rescue Member::AlreadyExistsError => exception
      respond_to do |format|
        format.html do
          redirect_to(
            edit_community_admin_member_path(
              current_community,
              existing_member),
            warning: exception.message)
        end
        format.json { render json: existing_member, status: :conflict }
      end
    end

    def edit
      @member.positions.build
    end

    def update
      @member.update(member_params)
      respond_to do |format|
        if @member.save
          format.html do
            redirect_to(
              community_admin_members_path(current_community),
              notice: 'Member was successfully updated.')
          end
          format.json { render json: @member, status: :created }
        else
          format.html { render 'edit', alert: 'Error updating member.' }
          format.json do
            render json: @member.errors, status: :unprocessable_entity
          end
        end
      end
    end

    def resend_invitation
      Member.invite!({ email: @member.email }, current_member)
      respond_to do |format|
        format.html do
          redirect_to(
            community_admin_members_path(current_community),
            notice: 'Member invitation was resend.')
        end
        format.json { render json: @member, status: :created }
      end
    end

    def destroy
      @member.destroy
      respond_to do |format|
        format.html do
          redirect_to(
            community_admin_members_path(current_community),
            notice: 'Member was successfully deleted.')
        end
        format.json { head :no_content }
      end
    end

    private

    def allow_without_password
      return unless params[:member][:password].blank? &&
                    params[:member][:password_confirmation].blank?
      params[:member].delete("password")
      params[:member].delete("password_confirmation")
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
        :description,
        notifications: NotificationMailer.action_methods.map(&:to_sym),
        positions_attributes:
          [
            :company_id,
            :role,
            :founder,
            :_destroy,
            :id
          ],
        social_media_links_attributes:
          [
            :id,
            :service,
            :url,
            :_destroy
          ]
      ).tap do |attrs|
        attrs[:community_id] = current_community.id
      end
      raise CanCan::AccessDenied unless current_member.
                                        can_assign_role? permitted[:role]
      permitted
    end

    def existing_member
      @existing_member ||= current_community.
                           members.
                           find_by(email: member_params[:email])
    end

    def invite_member(&block)
      raise Member::AlreadyExistsError if existing_member

      Member.invite!(member_params, current_member, &block)
    end
  end
end
