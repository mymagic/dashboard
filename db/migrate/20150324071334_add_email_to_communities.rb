class AddEmailToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :email, :string
  end
end
