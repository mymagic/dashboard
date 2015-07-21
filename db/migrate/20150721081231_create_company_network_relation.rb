class CreateCompanyNetworkRelation < ActiveRecord::Migration
  def change
    create_table :companies_networks do |t|
      t.references :network, index: true
      t.references :company, index: true
    end
  end
end
