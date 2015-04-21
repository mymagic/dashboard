require 'rails_helper'

RSpec.describe Admin::MembersController, type: :controller do
  describe "GET #index" do
    let(:community) { create(:community) }
    let(:response) { get(:index, community_id: community) }
    it_behaves_like "accessible by", :administrator, :staff
    describe 'assigning members' do
      let!(:active_member) { create(:member, :confirmed, community: community) }
      let!(:invited_member) { create(:member, :invited, community: community) }
      let!(:administrator) { create(:administrator, :confirmed, community: community) }
      before do
        login(administrator)
        get :index, community_id: community
      end
      it 'assigns the correct active members' do
        expect(assigns(:active_members)).to contain_exactly(administrator, active_member)
      end
      it 'assigns the correct invited members' do
        expect(assigns(:invited_members)).to eq [invited_member]
      end
    end
  end

  describe "GET #edit" do
    let(:community) { create(:community) }
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
    let(:community) { create(:community) }
    let(:response) { patch(:update, id: member, community_id: community, member: { first_name: 'New First Name' }) }
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
    let(:community) { create(:community) }
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
    let(:community) { create(:community) }
    let(:member_required_attributes) { { email: 'email@example.com' } }

    def invite_new_member(attributes = {})
      put :create, community_id: community, member: (member_required_attributes).merge(attributes)
    end

    it_behaves_like "accessible by", :administrator, :staff do
      let(:response) { invite_new_member }
    end

    context 'as Administrator' do
      let(:administrator) { create(:administrator, :confirmed, community: community) }
      before { login(administrator) }

      describe 'inviting an Administrator' do
        before { invite_new_member(role: 'administrator') }
        subject { community.members.find_by(email: member_required_attributes[:email]) }
        it { is_expected.to be_administrator }
      end

      describe 'inviting a Staff Member' do
        before { invite_new_member(role: 'staff') }
        subject { community.members.find_by(email: member_required_attributes[:email]) }
        it { is_expected.to be_staff }
      end

      describe 'inviting a Regular Member' do
        let(:company) { create(:company, community: community) }
        let(:position) { create(:position, community: community) }
        before do
          invite_new_member(
            role: '',
            companies_positions_attributes: [
              company_id: company.id, position_id: position.id, approver_id: administrator.id]
          )
        end
        subject { Member.find_by(email: member_required_attributes[:email]) }
        it { is_expected.to be_regular_member }
      end

      describe 'inviting an existing member' do
        let(:existing_member) { create(:member, community: community) }
        subject { invite_new_member(email: existing_member.email) }
        it 'redirects to the member edit path' do
          expect(subject).
            to redirect_to(
                 edit_community_admin_member_path(community, existing_member))
        end
      end
    end
  end
end
