require 'rails_helper'

RSpec.describe CompaniesMembersPosition, type: :model do
  context 'validations' do
    subject { create(:companies_members_position) }

    it { is_expected.to validate_presence_of(:member) }
    it { is_expected.to validate_presence_of(:company) }
    it { is_expected.to validate_presence_of(:position) }

    context 'with a c-m-p with same company, member and position present' do
      it 'works' do
        expect {
          create(:companies_members_position, company: subject.company, position: subject.position, member: subject.member)
        }.to raise_exception(ActiveRecord::RecordNotUnique)
      end
    end
  end

  context 'scopes' do
    let!(:pending) { create(:companies_members_position) }
    let!(:approved) { create(:companies_members_position, :approved) }

    context 'approved' do
      subject { CompaniesMembersPosition.approved }
      it { is_expected.to include(approved) }
      it { is_expected.to_not include(pending) }
    end

    context 'pending' do
      subject { CompaniesMembersPosition.pending }
      it { is_expected.to include(pending) }
      it { is_expected.to_not include(approved) }
    end
  end

  describe '#members_last_manager_position_in_company?' do
    let(:community) { create(:community) }
    let(:position) { create(:position, community: community) }
    let(:managable_cmp) { create(:companies_members_position, :managable, :approved, position: position) }
    let(:unmanagable_cmp) { create(:companies_members_position, :approved, position: position) }
    let(:member) { create(:member, :confirmed, community: community) }

    context 'can_manage_company as true' do
      subject { managable_cmp.members_last_manager_position_in_company?(member) }

      context 'member as myself' do
        before { managable_cmp.update(member_id: member.id) }

        it { is_expected.to eq(true) }
      end

      context 'member as another' do
        it { is_expected.to eq(false) }
      end
    end

    context 'can_manage_company as false' do
      subject { unmanagable_cmp.members_last_manager_position_in_company?(member) }

      context 'member as myself' do
        before { managable_cmp.update(member_id: member.id) }

        it { is_expected.to eq(false) }
      end

      context 'member as another' do
        it { is_expected.to eq(false) }
      end
    end
  end
end
