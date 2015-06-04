module FilterConcern
  extend ActiveSupport::Concern

  protected

  def filter
    @filter ||= (params[:filter] || default_filter).to_sym
  end
end
