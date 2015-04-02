require 'rails_helper'

RSpec.describe MembersController, type: :controller do
  describe "GET #index" do
    let(:community) { create(:community) }
    let(:response) { get(:index, community_id: community) }
    let(:members) { Member }
    it_behaves_like "accessible by", :administrator, :mentor, :staff, :regular_member
    describe 'assigning members' do
      let!(:active_member) { create(:member, :confirmed, community: community) }
      let!(:invited_member) { create(:member, :invited, community: community) }
      let!(:member) { create(:member, :confirmed, community: community) }
      before do
        login(member)
        get :index, community_id: community
      end
      it 'assigns the correct active members' do
        expect(assigns(:members)).to contain_exactly(member, active_member)
      end
    end
  end

  describe "GET #show" do
    let(:community) { create(:community) }
    let(:member) { create(:member, community: community) }
    let(:response) { get(:show, id: member, community_id: community) }
    it_behaves_like "accessible by", :administrator, :mentor, :staff, :regular_member
  end

  describe "POST #create" do
    let(:member_required_attributes) { { email: 'email@example.com' } }
    let(:community) { create(:community) }
    let(:company) { create(:company, community: community) }


    def invite_new_member(attributes = {})
      put :create, community_id: company.community, company_id: company, member: (member_required_attributes).merge(attributes)
    end

    it_behaves_like "accessible by", :administrator, :staff do
      let(:response) { invite_new_member }
    end

    context 'as manager of company' do
      let(:member) { create(:member, :confirmed, community: community) }
      let(:position) { create(:position, community: community) }
      before do
        CompaniesMembersPosition.create(
          position: position,
          member: member,
          company: company,
          approved: true,
          can_manage_company: true
        )
        login(member)
      end

      describe 'inviting a Member to the company' do
        before do
          invite_new_member(
            companies_positions_attributes: [
              company_id: company.id, position_id: position.id, approved: true]
          )
        end
        subject { Member.find_by(email: member_required_attributes[:email]) }
        it { is_expected.to be_regular_member }
      end
    end

    context 'as Administrator' do
      before { login_administrator }

      describe 'inviting a Member to the company' do
        let(:position) { create(:position, community: community) }
        before do
          invite_new_member(
            companies_positions_attributes: [
              company_id: company.id, position_id: position.id, approved: true]
          )
        end
        subject { Member.find_by(email: member_required_attributes[:email]) }
        it { is_expected.to be_regular_member }
      end
    end
  end
end
