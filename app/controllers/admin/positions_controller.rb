module Admin
  class PositionsController < AdminController
    load_and_authorize_resource through: :current_community

    def index
      @positions = @positions.ordered
    end

    def new
    end

    def create
      respond_to do |format|
        if @position.update_attributes(position_params)
          format.html { redirect_to community_admin_positions_path(current_community), notice: 'Position was successfully created.' }
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
          format.html { redirect_to community_admin_positions_path(current_community), notice: 'Position was successfully updated.' }
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
        format.html { redirect_to community_admin_positions_path(current_community), notice: 'Position was successfully deleted.' }
        format.json { head :no_content }
      end
    end

    private

    def position_params
      params.require(:position).permit(:name, :priority_order_position)
    end
  end
end
