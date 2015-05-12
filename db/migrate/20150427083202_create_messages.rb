class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.references :sender, null: false, index: true
      t.references :receiver, null: false, index: true
      t.text :body, null: false

      t.timestamps null: false
    end
  end
end
