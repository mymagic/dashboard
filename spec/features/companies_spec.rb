require 'rails_helper'

RSpec.describe 'OfficeHours', type: :feature, js: false do
  let!(:community) { create(:community) }
  let!(:administrator) { create(:administrator, :confirmed, community: community) }
  let!(:company) { create(:company, community: community) }

  before { as_user administrator }

  scenario 'viewing companies' do
    visit community_companies_path(community)

    expect(page).to have_content(company.name)
  end

  scenario 'viewing the company' do
    visit community_companies_path(community)
    click_on company.name

    expect(page).to have_content(company.name)
    expect(page).to have_content(company.website)
  end
end
