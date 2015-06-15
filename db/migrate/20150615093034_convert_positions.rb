class ConvertPositions < ActiveRecord::Migration
  def up
    rename_table :positions, :old_positions
    create_table :positions do |t|
      t.references :member, null: false, index: true
      t.references :community, null: false, index: true
      t.references :company, null: false, index: true
      t.boolean :founder, null: false, default: false
      t.string :role

      t.timestamps null: false
    end
    cmps = execute("select * from companies_members_positions INNER JOIN "\
                   "old_positions ON "\
                   "companies_members_positions.position_id = old_positions.id")

    cmps.each do |cmp|
      Position.create(
        member_id: cmp['member_id'],
        company_id: cmp['company_id'],
        community_id: cmp['community_id'],
        founder: cmp['can_manage_company'] == 't',
        role: cmp['name']
      )
    end
    execute "DROP TABLE old_positions CASCADE"
    execute "DROP TABLE companies_members_positions"
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
