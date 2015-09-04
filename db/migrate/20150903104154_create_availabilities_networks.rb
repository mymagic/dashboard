class CreateAvailabilitiesNetworks < ActiveRecord::Migration
  def change
    create_table :availabilities_networks do |t|
      t.belongs_to :availability, index: true
      t.belongs_to :network, index: true
    end

    reversible do |dir|
      dir.up do
        Availability.find_each do |availability|
          availability.network.availabilities << availability
        end
      end
      dir.down do
        Availability.find_each do |availability|
          availability.update(network: availability.networks.first)
        end
      end
    end

    remove_reference :availabilities, :network
  end
end
