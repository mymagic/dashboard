class CreateNetworks < ActiveRecord::Migration
  def change
    create_table :networks do |t|
      t.string :name
      t.references :community, index: true, foreign_key: true
      t.string :slug

      t.timestamps null: false
    end
    add_index :networks, :slug, unique: true

    Community.find_each do |community|
      community.networks.create(name: 'network')
    end
  end
end
