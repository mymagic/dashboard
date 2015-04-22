require 'rails_helper'

RSpec.describe CompaniesMembersPositionsController, type: :controller do
  let(:community) { create(:community) }
  let(:company) { create(:company, community: community) }

  describe "GET #index" do
    describe 'accessing the page' do
      let(:response) do
        get(:index, company_id: company, community_id: community)
      end
      it_behaves_like "accessible by", :administrator, :staff

      let(:manager) { create(:member, :confirmed, community: community) }
      let(:regular_member) { create(:member, :confirmed, community: community) }
      context 'as a manager' do
        before do
          create(:companies_members_position,
                 :approved,
                 :managable,
                 position: create(:position, community: community),
                 company: company,
                 member: manager)
          login(manager)
        end
        it 'displays the page without errors' do
          expect(response).to_not redirect_to(community_path(community))
          expect(response).
            to_not redirect_to(new_member_session_path(community))
        end
      end
      context 'as a regular member' do
        before { login(regular_member) }
        it 'redirects to community path (not authorized)' do
          expect(response).to redirect_to(community_path(community))
        end
      end
    end

    describe 'assigning members' do
      let!(:position) { create(:position, community: community) }
      let!(:administrator) do
        create(:administrator, :confirmed, community: community)
      end
      let!(:approved_cmp) do
        create(
          :companies_members_position,
          :approved,
          position: position,
          company: company)
      end
      let!(:pending_cmp) do
        create(
          :companies_members_position,
          position: position,
          company: company)
      end
      before do
        login(administrator)
        get :index, company_id: company, community_id: community
      end
      it 'assigns the correct approved company member positions' do
        expect(assigns(:approved_companies_members_positions)).
          to include(approved_cmp)
        expect(assigns(:approved_companies_members_positions)).
          to_not include(pending_cmp)
      end
      it 'assigns the correct pending company member positions' do
        expect(assigns(:pending_companies_members_positions)).
          to eq [pending_cmp]
      end
    end
  end

  describe 'POST #create' do
    let(:position) { create(:position, community: community) }
    let(:companies_members_position_required_attributes) do
      { position_id: position.id }
    end

    def create_new_position(attributes = {})
      post(
        :create,
        company_id: company,
        community_id: community,
        companies_members_position: (
          companies_members_position_required_attributes).merge(attributes)
      )
    end

    it_behaves_like "accessible by", :staff, :administrator, :member do
      let(:response) { create_new_position }
    end

    describe 'for a member' do
      let(:member) { create(:member, :confirmed, community: community) }

      before { login(member) }

      it 'creates a new (pending) companies members position' do
        expect { create_new_position }.
          to change { member.companies_positions.count }.from(1).to(2)
      end
    end
  end
end
