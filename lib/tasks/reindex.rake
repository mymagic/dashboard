namespace :elasticsearch do
  desc 'Resets the ElasticSearch index'
  task reindex: :environment do
    Dir[Rails.root.join('app/models/**/*.rb')].each do |file|
      begin require file
      rescue
        nil
      end
    end

    puts 'Importing indexable models into ElasticSearch...'
    puts ' ----> Auto detecting indexable models...'
    ActiveRecord::Base.subclasses.each do |model|
      if model.respond_to?(:__elasticsearch__)
        print "       #{model} (#{model.count} records)... "
        model.__elasticsearch__.import(force: true, batch_size: 1000)
        puts 'Done.'
      end
    end
  end
end
