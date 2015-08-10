class CreateMemberships < ActiveRecord::Migration
  def change
    create_table :memberships do |t|
      t.references :member, index: true, foreign_key: true
      t.references :network, index: true, foreign_key: true

      t.timestamps null: false
    end

    reversible do |dir|
      dir.up do
        Community.find_each do |community|
          community.members.find_each do |member|
            member.networks << community.default_network
          end
        end
      end
    end

  end
end
