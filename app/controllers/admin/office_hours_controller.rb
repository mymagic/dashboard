module Admin
  class OfficeHoursController < AdminController
    load_and_authorize_resource
    skip_authorize_resource

    def index
    end

    def new
      @office_hour = OfficeHour.new
    end

    def create
      @office_hour = OfficeHour.new(office_hour_params)
      respond_to do |format|
        if @office_hour.save
          format.html { redirect_to admin_office_hours_path, notice: 'Office Hour was successfully created.' }
          format.json { render json: @office_hour, status: :created }
        else
          format.html { redirect_to :back, alert: 'Error creating office hour.' }
          format.json { render json: @office_hour.errors, status: :unprocessable_entity }
        end
      end
    end

    def edit
    end

    def update
      @office_hour.update(office_hour_params)
      respond_to do |format|
        if @office_hour.save
          format.html { redirect_to admin_office_hours_path, notice: 'Office Hour was successfully updated.' }
          format.json { render json: @office_hour, status: :created }
        else
          format.html { redirect_to :back, alert: 'Error updating office hour.' }
          format.json { render json: @office_hour.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @office_hour.destroy
      respond_to do |format|
        format.html { redirect_to :back, notice: 'Office Hour was successfully deleted.' }
        format.json { head :no_content }
      end
    end

    private

    def office_hour_params
      params.require(:office_hour).permit(
        :mentor_id,
        :participant_id,
        :time_zone,
        :"time(1i)",
        :"time(2i)",
        :"time(3i)",
        :"time(4i)",
        :"time(5i)")
    end
  end
end