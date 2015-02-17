class CreateCompaniesMembersPositions < ActiveRecord::Migration
  def change
    create_table :companies_members_positions do |t|
      t.references :member, index: true
      t.references :company, index: true
      t.references :position, index: true

      t.timestamps null: false
    end
    add_foreign_key :companies_members_positions, :members
    add_foreign_key :companies_members_positions, :companies
    add_foreign_key :companies_members_positions, :positions
  end
end
