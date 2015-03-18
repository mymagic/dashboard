require 'rails_helper'

RSpec.describe MembersController, type: :controller do
  describe "GET #index" do
    it_behaves_like "accessible by", :administrator, :mentor, :staff, :regular_member do
      let(:response) { get(:index, community_id: current_community.id) }
    end
  end

  describe "GET #show" do
    let(:member) { create(:member, community: current_community) }
    it_behaves_like "accessible by", :administrator, :mentor, :staff, :regular_member do
      let(:response) { get(:show, id: member, community_id: current_community.id) }
    end
  end

  describe "POST #create" do
    let(:member_required_attributes) { { email: 'email@example.com' } }
    let(:company) { create(:company) }

    def invite_new_member(attributes = {})
      put :create, company_id: company.id, member: (member_required_attributes).merge(attributes)
    end

    it_behaves_like "accessible by", :administrator, :staff do
      let(:response) { invite_new_member }
    end

    context 'as manager of company' do
      let(:member) { create(:member, :confirmed) }
      let(:position) { create(:position) }
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
        let(:position) { create(:position) }
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
