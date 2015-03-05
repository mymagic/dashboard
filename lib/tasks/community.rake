namespace :community do
  desc 'Add new community'
  task create: :environment do |t, args|
    params = {
      name: ENV['COMMUNITY_NAME'],
      slug: ENV['COMMUNITY_SLUG']
    }

    begin
      Rails.logger.info 'Creating a community...'
      Community.create!(params)
    rescue => ex
      Rails.logger.error "Fail to create a community: #{ex.message}"
    end
  end
end
