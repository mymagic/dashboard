module NetworksConcern
  extend ActiveSupport::Concern

  def default_network
    networks.first
  end
end
