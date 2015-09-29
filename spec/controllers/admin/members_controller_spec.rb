require 'rails_helper'

RSpec.describe Admin::MembersController, type: :controller do
  let(:community) { create(:community) }
  let(:network) { community.default_network }

  describe "GET #index" do
    let(:response) { get(:index, community_id: community) }
    it_behaves_like "accessible by", :administrator, :staff
    describe 'assigning members' do
      let!(:active_member) do
        create(:member, :confirmed, community: community)
      end
      let!(:invited_member) do
        create(:member, :invited, community: community)
      end
      let!(:administrator) do
        create(:administrator, :confirmed, community: community)
      end
      before do
        login(administrator)
        stub_valid_cookie
        get :index, community_id: community
      end
      it 'assigns the correct active members' do
        expect(assigns(:active_members)).
          to contain_exactly(administrator, active_member)
      end
      it 'assigns the correct invited members' do
        expect(assigns(:invited_members)).to eq [invited_member]
      end
    end
  end

  describe "GET #edit" do
    let(:response) { get(:edit, id: member, community_id: community) }
    context 'an administrator' do
      let(:member) { create(:administrator, community: community) }
      it_behaves_like "accessible by", :administrator
    end
    context 'a staff member' do
      let(:member) { create(:staff, community: community) }
      it_behaves_like "accessible by", :administrator
    end
    context 'a mentor' do
      let(:member) { create(:mentor, community: community) }
      it_behaves_like "accessible by", :administrator, :staff
    end
    context 'a regular member' do
      let(:member) { create(:mentor, community: community) }
      it_behaves_like "accessible by", :administrator, :staff
    end
  end

  describe 'PATCH #update' do
    let(:response) do
      patch(
        :update,
        id: member,
        community_id: community,
        member: { first_name: 'New First Name' }
      )
    end
    context 'an administrator' do
      let(:member) { create(:administrator, community: community) }
      it_behaves_like "accessible by", :administrator
    end
    context 'a staff member' do
      let(:member) { create(:staff, community: community) }
      it_behaves_like "accessible by", :administrator
    end
    context 'a mentor' do
      let(:member) { create(:mentor, community: community) }
      it_behaves_like "accessible by", :administrator, :staff
    end
    context 'a regular member' do
      let(:member) { create(:mentor, community: community) }
      it_behaves_like "accessible by", :administrator, :staff
    end
  end

  describe 'DELETE #destroy' do
    let(:response) { delete(:destroy, id: member, community_id: community) }
    context 'an administrator' do
      let(:member) { create(:administrator, community: community) }
      it_behaves_like "accessible by", :administrator
    end
    context 'a staff member' do
      let(:member) { create(:staff, community: community) }
      it_behaves_like "accessible by", :administrator
    end
    context 'a mentor' do
      let(:member) { create(:mentor, community: community) }
      it_behaves_like "accessible by", :administrator, :staff
    end
    context 'a regular member' do
      let(:member) { create(:mentor, community: community) }
      it_behaves_like "accessible by", :administrator, :staff
    end
  end

  describe "PUT #create" do
    let(:member_required_attributes) do
      {
        email: 'email@example.com',
        network_ids: [community.default_network.id]
      }
    end

    def invite_new_member(attributes = {})
      put(
        :create,
        community_id: community,
        member: (member_required_attributes).merge(attributes)
      )
    end

    it_behaves_like "accessible by", :administrator, :staff do
      let(:response) { invite_new_member }
    end

    context 'as Administrator' do
      let(:administrator) do
        create(:administrator, :confirmed, community: community)
      end
      before do
        login(administrator)
        stub_valid_cookie
      end

      describe 'inviting an Administrator' do
        before { invite_new_member(role: 'administrator') }
        subject do
          community.members.find_by(email: member_required_attributes[:email])
        end
        it { is_expected.to be_administrator }
      end

      describe 'inviting a Staff Member' do
        before { invite_new_member(role: 'staff') }
        subject do
          community.members.find_by(email: member_required_attributes[:email])
        end
        it { is_expected.to be_staff }
      end

      describe 'inviting a Regular Member' do
        let(:company) { create(:company, community: community) }
        let(:position) { create(:position, community: community) }
        before do
          invite_new_member(
            role: '',
            positions_attributes: [company_id: company.id]
          )
        end
        subject(:invited_member) do
          Member.find_by(email: member_required_attributes[:email])
        end

        it 'invites a regular member' do
          expect(invited_member).to be_regular_member
        end

        it "sets the cmp's company to the current company" do
          expect(invited_member.companies.first).to eq(company)
        end
      end

      describe 'inviting an existing member' do
        let(:existing_member) { create(:member, community: community) }
        subject { invite_new_member(email: existing_member.email) }
        it 'redirects to the member edit path' do
          expect(subject).
            to redirect_to(
              edit_community_admin_member_path(community, existing_member)
            )
        end
      end
    end
  end
end
