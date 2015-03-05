require 'optparse'

namespace :community do
  desc 'Add new community'
  task create: :environment do
    options = {}

    parser = OptionParser.new do |opts|
      opts.banner = 'Usage: rake community:add [options]'
      opts.on('-n', '--name {community_name}') { |name| options[:name] = name }
      opts.on('-s', '--slug {community_slug}') { |slug| options[:slug] = slug }
    end
    args = parser.order!(ARGV) {}
    parser.parse!(args)

    begin
      puts 'Creating a community...'
      Community.create!(options)
    rescue => ex
      puts "Fail to create a community: #{ex.message}"
    end

    exit 0
  end
end
