require 'rails_helper'

RSpec.describe Admin::CompaniesController, type: :controller do
  let(:community) { create(:community) }
  let(:network) { community.default_network }  

  describe "GET #index" do
    let(:response) { get(:index, community_id: community) }
    it_behaves_like "accessible by", :administrator, :staff
  end

  describe "GET #edit" do
    let(:company) { create(:company, community: community) }
    let(:response) { get(:edit, id: company, community_id: community) }
    it_behaves_like "accessible by", :administrator, :staff
  end

  describe 'PATCH #update' do
    let(:company) { create(:company, community: community) }
    let(:response) do
      get(
        :edit,
        id: company,
        community_id: community,
        company: { name: 'New Company Name'})
    end
    it_behaves_like "accessible by", :administrator, :staff
  end

  describe 'DELETE #destroy' do
    let(:company) { create(:company, community: community) }
    let(:response) { delete(:destroy, id: company, community_id: community) }
    it_behaves_like "accessible by", :administrator
  end

  describe "PUT #create" do
    let(:company_required_attributes) { { name: 'New Company' } }

    def create_new_company(attributes = {})
      put(
        :create,
        community_id: community,
        company: (company_required_attributes).merge(attributes))
    end

    it_behaves_like "accessible by", :administrator, :staff do
      let(:response) { create_new_company }
    end
  end
end
