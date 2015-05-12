module ElasticsearchHelpers

  class ElasticsearchTestUtils

    # Initialize the search utilities.
    def initialize
      @models = []
      @client = nil
    end

    # Create indices for the specific models as well as importing all existing
    # data to it. If client has not been assigned, it will be assumed from
    # the provided model.
    def setup!(*models)
      @models += [*models]
      @client ||= @models.first.__elasticsearch__.client

      @models.each do |model|
        indices = @client.indices
        idx_name = model.index_name
        unless indices.exists(index: idx_name)
          indices.create(index: idx_name)
          wait!
        end
        
        model.import
        wait!
      end
    end

    # Delete all indices created using setup!.
    def teardown!
      @models.each do |model|
        indices = @client.indices
        idx_name = model.index_name
        if indices.exists(index: idx_name)
          indices.delete(index: idx_name)
          wait!
        end
      end
    end

    # Wait for ElasticSearch cluster to be properly populated. This method
    # MUST be called after any import operation including after creating
    # a new model record that is going to be used in ElasticSearch.
    def wait!
      @client.indices.refresh
      @client.cluster.health(wait_for_status: 'yellow')
    end

    # Count number of items in an index for a model.
    def count(model)
      wait!
      @client.count(index: model.index_name)['count']
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
      0
    end

  end

  # Wrapper for accessing ElasticSearch utilities.
  def elasticsearch
    @elasticsearch ||= ElasticsearchTestUtils.new
  end

end

RSpec.configure do |config|
  config.include ElasticsearchHelpers

  config.before(:each) do |example|
    if example.metadata[:elasticsearch].present?
      elasticsearch.setup!(example.metadata[:elasticsearch])
    end
  end

  config.after(:each) do |example|
    if example.metadata[:elasticsearch].present?
      elasticsearch.teardown!
    end
  end

end
