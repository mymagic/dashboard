module TagsConcern
  extend ActiveSupport::Concern

  def tags
    tags = tags_class.
           where(community: current_community).
           where("name ILIKE ?", "#{ params[:q] }%").
           order(:name).
           pluck(:name)

    respond_to do |format|
      format.json { render json: tags }
    end
  end

  protected

  def tag
    @tag ||= begin
      tags_class.find(params[:tag_id]) if params[:tag_id]
    end
  end

  def tags_class
    "#{controller_name.classify}Tag".constantize
  end
end
