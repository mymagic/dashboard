class CreateCompanyNetworkRelation < ActiveRecord::Migration
  def change
    create_table :companies_networks do |t|
      t.references :network, index: true
      t.references :company, index: true
    end

    reversible do |dir|
      dir.up do
        Community.find_each do |community|
          community.companies.find_each do |company|
            company.networks << community.default_network
          end
        end
      end
    end

  end
end
