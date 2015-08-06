namespace :community do
  desc 'Add new community'
  task create: :environment do |t, args|
    usage = "Usage: rake community:create COMMUNITY_NAME='<NAME>' " \
            "ADMIN_EMAIL='<EMAIL>' [COMMUNITY_SLUG='slug']"

    abort "Missing COMMUNITY_NAME, #{usage}" if ENV['COMMUNITY_NAME'].nil?
    abort "Missing ADMIN_EMAIL, #{usage}"    if ENV['ADMIN_EMAIL'].nil?

    ActiveRecord::Base.transaction do
      begin
        Rails.logger.info 'Creating a community...'
        community = Community.create!(
          name: ENV['COMMUNITY_NAME'],
          slug: ENV['COMMUNITY_SLUG']
        )

        Rails.logger.info 'Creating an administrator...'
        Member.invite!(
          email: ENV['ADMIN_EMAIL'],
          community_id: community.id,
          network_ids: [community.default_network.id],
          role: 'administrator',
          time_zone: Time.zone.name
        ).valid_invitation? || raise(ActiveRecord::RecordInvalid)
      rescue => ex
        Rails.logger.error "Fail to create a community: #{ex.message}"
        raise ActiveRecord::Rollback
      end
    end
  end
end
