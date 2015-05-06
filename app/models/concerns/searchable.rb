module Searchable
  extend ActiveSupport::Concern

  included do
    include Elasticsearch::Model
    index_name("#{self.name.underscore}_#{Figaro.env.elasticsearch_index}")

    host = Figaro.env.bonsai_url || Figaro.env.elasticsearch_host
    self.__elasticsearch__.client = Elasticsearch::Client.new host: host if host.present?
  end
end
