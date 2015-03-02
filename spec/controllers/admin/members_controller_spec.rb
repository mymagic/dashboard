require 'rails_helper'

RSpec.describe Admin::MembersController, type: :controller do
  describe "GET #index" do
    it_behaves_like "only accessible by administrator" do
      let(:response) { get(:index) }
    end
  end

  describe "GET #new" do
    it_behaves_like "only accessible by administrator" do
      let(:response) { get(:new) }
    end
  end

  describe "PUT #create" do
    let(:member_required_attributes) { { email: 'email@example.com' } }

    def invite_new_member(attributes = {})
      put :create, member: (member_required_attributes).merge(attributes)
    end

    it_behaves_like "only accessible by administrator" do
      let(:response) { invite_new_member }
    end

    context 'as Administrator' do
      before { login_administrator }
      describe 'inviting an Administrator' do
        before { invite_new_member(role: 'administrator') }
        subject { Member.find_by(email: member_required_attributes[:email]) }
        it { is_expected.to be_administrator }
      end

      describe 'inviting a Staff Member' do
        before { invite_new_member(role: 'staff') }
        subject { Member.find_by(email: member_required_attributes[:email]) }
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