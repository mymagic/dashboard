module Admin
  class PositionsController < AdminController
    load_and_authorize_resource
    skip_authorize_resource

    def index
    end

    def new
      @position = Position.new
    end

    def create
      @position = Position.new(position_params)
      respond_to do |format|
        if @position.save
          format.html { redirect_to admin_positions_path, notice: 'Position was successfully created.' }
          format.json { render json: @position, status: :created }
        else
          format.html { render 'new', alert: 'Error creating position.' }
          format.json { render json: @position.errors, status: :unprocessable_entity }
        end
      end
    end

    def edit
    end

    def update
      @position.update(position_params)
      respond_to do |format|
        if @position.save
          format.html { redirect_to admin_positions_path, notice: 'Position was successfully updated.' }
          format.json { render json: @position, status: :created }
        else
          format.html { render 'edit', alert: 'Error updating position.' }
          format.json { render json: @position.errors, status: :unprocessable_entity }
        end
      end
    end

    def destroy
      @position.destroy
      respond_to do |format|
        format.html { redirect_to :back, notice: 'Position was successfully deleted.' }
        format.json { head :no_content }
      end
    end

    private

    def position_params
      params.require(:position).permit(:name)
    end
  end
end
