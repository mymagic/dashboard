require 'rails_helper'

RSpec.describe Admin::MembersController, type: :controller do
  describe "GET #index" do
    let(:member) { create(:administrator) }
    it_behaves_like "accessible by", :administrator, :staff do
      let(:response) { get(:index, community_id: current_community.try(:id)) }
    end
  end

  describe "GET #edit" do
    context 'an administrator' do
      let(:member) { create(:administrator) }
      it_behaves_like "accessible by", :administrator do
        let(:response) { get(:edit, id: member, community_id: current_community.try(:id)) }
      end
    end
    context 'a staff member' do
      let(:member) { create(:staff) }
      it_behaves_like "accessible by", :administrator do
        let(:response) { get(:edit, id: member, community_id: current_community.try(:id)) }
      end
    end
    context 'a mentor' do
      let(:member) { create(:mentor) }
      it_behaves_like "accessible by", :administrator, :staff do
        let(:response) { get(:edit, id: member, community_id: current_community.try(:id)) }
      end
    end
    context 'a regular member' do
      let(:member) { create(:mentor) }
      it_behaves_like "accessible by", :administrator, :staff do
        let(:response) { get(:edit, id: member, community_id: current_community.try(:id)) }
      end
    end
  end

  describe 'PATCH #update' do
    context 'an administrator' do
      let(:member) { create(:administrator) }
      it_behaves_like "accessible by", :administrator do
        let(:response) { patch(:update, id: member, community_id: current_community.try(:id), member: { first_name: 'New First Name' }) }
      end
    end
    context 'a staff member' do
      let(:member) { create(:staff) }
      it_behaves_like "accessible by", :administrator do
        let(:response) { patch(:update, id: member, community_id: current_community.try(:id), member: { first_name: 'New First Name' }) }
      end
    end
    context 'a mentor' do
      let(:member) { create(:mentor) }
      it_behaves_like "accessible by", :administrator, :staff do
        let(:response) { patch(:update, id: member, community_id: current_community.try(:id), member: { first_name: 'New First Name' }) }
      end
    end
    context 'a regular member' do
      let(:member) { create(:mentor) }
      it_behaves_like "accessible by", :administrator, :staff do
        let(:response) { patch(:update, id: member, community_id: current_community.try(:id), member: { first_name: 'New First Name' }) }
      end
    end
  end

  describe 'DELETE #destroy' do
    context 'an administrator' do
      let(:member) { create(:administrator) }
      it_behaves_like "accessible by", :administrator do
        let(:response) { delete(:destroy, id: member, community_id: current_community.try(:id)) }
      end
    end
    context 'a staff member' do
      let(:member) { create(:staff) }
      it_behaves_like "accessible by", :administrator do
        let(:response) { delete(:destroy, id: member, community_id: current_community.try(:id)) }
      end
    end
    context 'a mentor' do
      let(:member) { create(:mentor) }
      it_behaves_like "accessible by", :administrator, :staff do
        let(:response) { delete(:destroy, id: member, community_id: current_community.try(:id)) }
      end
    end
    context 'a regular member' do
      let(:member) { create(:mentor) }
      it_behaves_like "accessible by", :administrator, :staff do
        let(:response) { delete(:destroy, id: member, community_id: current_community.try(:id)) }
      end
    end
  end

  describe "PUT #create" do
    let(:member_required_attributes) { { email: 'email@example.com' } }

    def invite_new_member(attributes = {})
      put :create, community_id: current_community.try(:id), member: (member_required_attributes).merge(attributes)
    end

    it_behaves_like "accessible by", :administrator, :staff do
      let(:response) { invite_new_member }
    end

    context 'as Administrator' do
      before { login_administrator }
      describe 'inviting an Administrator' do
        before { invite_new_member(role: 'administrator') }
        subject { current_community.members.find_by(email: member_required_attributes[:email]) }
        it { is_expected.to be_administrator }
      end

      describe 'inviting a Staff Member' do
        before { invite_new_member(role: 'staff') }
        subject { current_community.members.find_by(email: member_required_attributes[:email]) }
        it { is_expected.to be_staff }
      end

      describe 'inviting a Regular Member' do
        let(:company) { create(:company) }
        let(:position) { create(:position) }
        before do
          invite_new_member(
            role: '',
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
