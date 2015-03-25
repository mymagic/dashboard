namespace :community do
  desc 'Add new community'
  task create: :environment do |t, args|
    params = {
      name: ENV['COMMUNITY_NAME'],
      slug: ENV['COMMUNITY_SLUG']
    }

    ActiveRecord::Base.transaction do
      begin
        Rails.logger.info 'Creating a community...'
        community = Community.create!(params)

        Rails.logger.info 'Creating an administrator...'
        Member.invite!(
          email: ENV['ADMIN_EMAIL'],
          community: community,
          role: 'administrator'
        ).valid_invitation? || admin.validate!
      rescue => ex
        Rails.logger.error "Fail to create a community: #{ex.message}"
        raise ActiveRecord::Rollback
      end
    end
  end
end
