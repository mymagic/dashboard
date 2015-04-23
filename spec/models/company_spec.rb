require 'rails_helper'

RSpec.describe Company, type: :model do
  context 'validations' do
    subject { build(:company) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:description).is_at_least(5) }
    it { is_expected.to allow_value('https://example.com', 'http://example.com').for(:website) }
    it { is_expected.to_not allow_value('ht://example.com', 'ftp://example.com').for(:website) }

    it { is_expected.to have_many(:companies_members_positions).dependent(:destroy) }
  end

  let(:company) { create(:company, name: 'ACME Corporation') }

  describe '#to_param' do
    subject { company.to_param }
    it { is_expected.to match(/-acme-corporation/) }
  end

  describe '#positions_with_members' do
    subject { company.positions_with_members }
    context 'as a new company' do
      it { is_expected.to be_empty }
    end
    context 'as a company with members' do
      let(:community) { company.community }
      let(:member) { create(:member, :confirmed, community: community) }
      let(:invited_member) { create(:member, :invited, community: community) }
      let(:position) { create(:position, community: community) }
      let(:other_position) { create(:position, community: community) }
      let!(:cmp_member) { create(:companies_members_position, :approved, member: member, position: position, company: company) }
      let!(:cmp_invited_member) { create(:companies_members_position, :approved, member: invited_member, position: position, company: company) }
      let!(:cmp_member_pending) { create(:companies_members_position, member: invited_member, position: other_position, company: company) }
      it { is_expected.to eq(position => [member]) }
      it 'does not include the invited but unconfirmed member in the position' do
        expect(subject[position]).to_not include(invited_member)
      end
      it 'includes the confirmed and approved member in that position' do
        expect(subject[position]).to include(member)
      end
      it 'does not include the pending position' do
        expect(subject.keys).to_not include(other_position)
      end
      it 'includes the approved position' do
        expect(subject.keys).to include(position)
      end
    end
  end

  describe '#managing_members' do
    let(:community) { create(:community) }
    let(:company) { create(:company, community: community) }
    let(:position) { create(:position, community: community) }
    let(:managing_member) { create(:member, :confirmed, community: community) }
    let(:unmanaging_member) { create(:member, :confirmed, community: community) }

    before { create(:companies_members_position, :approved, :managable, { company: company, member: managing_member, position: position }) }
    subject { company.managing_members }

    it { is_expected.to include(managing_member) }
    it { is_expected.to_not include(unmanaging_member) }
  end
end
