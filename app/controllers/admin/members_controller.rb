module Admin
  class MembersController < AdminController
    load_and_authorize_resource

    before_action :allow_without_password, only: :update

    def index
    end

    def new
      @member = Member.new
    end

    def create
      @member = Member.new(member_params)
      respond_to do |format|
        if @member.save
          format.html { redirect_to :back, notice: 'Member was successfully created.' }
          format.json { render json: @member, status: :created }
        else
          format.html { redirect_to :back, alert: 'Error creating member.' }
          format.json { render json: @member.errors, status: :unprocessable_entity }
        end
      end
    end

    def edit
    end

    def update
      @member.update(member_params)
      respond_to do |format|
        if @member.save
          format.html { redirect_to :back, notice: 'Member was successfully updated.' }
          format.json { render json: @member, status: :created }
        else
          format.html { redirect_to :back, alert: 'Error updating member.' }
          format.json { render json: @member.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @member.destroy
      respond_to do |format|
        format.html { redirect_to :back, notice: 'Member was successfully deleted.' }
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
      params.require(:member).permit(
        :first_name,
        :last_name,
        :email,
        :password,
        :password_confirmation,
        :role)
    end
  end
end
