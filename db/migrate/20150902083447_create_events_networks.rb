class CreateEventsNetworks < ActiveRecord::Migration
  def change
    create_table :events_networks do |t|
      t.belongs_to :event, index: true
      t.belongs_to :network, index: true
    end

    reversible do |dir|
      dir.up do
        Event.find_each do |event|
          event.network.events << event
        end
      end
      dir.down do
        Event.find_each do |event|
          events.update(network: event.networks.first)
        end
      end
    end

    remove_reference :events, :network

  end
end
