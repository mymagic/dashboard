module TagsConcern
  extend ActiveSupport::Concern

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
