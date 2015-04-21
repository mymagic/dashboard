require 'rails_helper'

RSpec.describe Position, type: :model do
  context 'validations' do
    subject { build(:position) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:community_id) }

    it { is_expected.to have_many(:companies_members_positions).dependent(:destroy) }
  end

  context 'class Methods' do
    let(:community) { create(:community) }
    let(:confirmed_member) { create(:member, :confirmed, community: community)}
    let(:unconfirmed_member) { create(:member, community: community) }
    let(:company) { create(:company, community: community) }
    let(:another_company) { create(:company, community: community) }
    let(:position) { create(:position, community: community) }
    let(:pending_position) { create(:position, community: community) }
    let(:unimportant_position) { create(:position, community: community) }

    let!(:approved_cmp_for_confirmed_member_at_other_company) {
      create(:companies_members_position,
             :approved,
             position: position,
             member: confirmed_member,
             company: another_company)
    }
    let!(:approved_cmp_for_confirmed_member) {
      create(:companies_members_position,
             :approved,
             position: position,
             member: confirmed_member,
             company: company)
    }
    let!(:approved_unimportant_cmp_for_confirmed_member) {
      create(:companies_members_position,
             :approved,
             position: unimportant_position,
             member: confirmed_member,
             company: company)
    }
    let!(:pending_cmp_for_confirmed_member) {
      create(:companies_members_position,
             position: pending_position,
             member: confirmed_member,
             company: company)
    }
    let!(:approved_cmp_for_unconfirmed_member) {
      create(:companies_members_position,
             :approved,
             position: position,
             member: unconfirmed_member,
             company: company)
    }
    let!(:pending_cmp_for_unconfirmed_member) {
      create(:companies_members_position,
             position: pending_position,
             member: unconfirmed_member,
             company: company)
    }
    describe '.positions_with_members' do
      subject(:company_positions_with_members) {
        Position.positions_with_members(company: company)
      }
      describe 'confirmed members' do
        let(:members) { company_positions_with_members.values.flatten }
        it 'includes confirmed members' do
          expect(members.select { |m| m.confirmed? }).to_not be_empty
        end
        it 'does not include unconfirmed members' do
          expect(members.select { |m| !m.confirmed? }).to be_empty
        end
      end
      describe 'approved companies members positions' do
        let(:cmps) {
          company_positions_with_members.map do |position, members|
            members.map do |member|
              CompaniesMembersPosition.where(
                company: company,
                member: member,
                position: position)
            end
          end.flatten
        }
        it 'includes no pending companies members positions' do
          expect(cmps.select{ |cmp| !cmp.approved? }).to be_empty
        end
        it 'includes approved companies members positions' do
          expect(cmps.select{ |cmp| cmp.approved? }).to_not be_empty
        end
      end
      describe 'order of the positions' do
        before do
          position.update_attribute :priority_order_position, :first
          unimportant_position.update_attribute :priority_order_position, :last
        end
        let(:positions) { company_positions_with_members.keys }
        it 'uses the priority_order_position for correct ordering' do
          expect(positions.first).to eq position
          expect(positions.last).to eq unimportant_position
        end
      end
      describe 'the return value' do
        it 'is a positions with members hash' do
          positions = company_positions_with_members.keys.first
          expect(position).to be_a(Position)
          expect(company_positions_with_members[position].first).to be_a(Member)
        end
      end
    end

    describe '.positions_in_companies' do
      subject(:member) { confirmed_member }
      subject(:positions_in_companies) {
        Position.positions_in_companies(member: member)
      }
      describe 'approved companies members positions' do
        let(:cmps) {
          positions_in_companies.map do |company, positions|
            positions.map do |position|
              CompaniesMembersPosition.where(
                company: company,
                member: member,
                position: position)
            end
          end.flatten
        }
        it 'includes no pending companies members positions' do
          expect(cmps.select{ |cmp| !cmp.approved? }).to be_empty
        end
        it 'includes approved companies members positions' do
          expect(cmps.select{ |cmp| cmp.approved? }).to_not be_empty
        end
      end

      describe 'order of the positions' do
        before do
          position.update_attribute :priority_order_position, :first
          unimportant_position.update_attribute :priority_order_position, :last
        end
        let(:positions) { positions_in_companies[company] }
        it 'uses the priority_order_position for correct ordering' do
          expect(positions.first).to eq position
          expect(positions.last).to eq unimportant_position
        end
      end

      describe 'the return value' do
        it 'is a companies with positions hash' do
          company = positions_in_companies.keys.first
          expect(company).to be_a(Company)
          expect(positions_in_companies[company].first).to be_a(Position)
        end
      end
    end

    describe '.all_possible' do
      subject { Position.all_possible(member: confirmed_member, company: company) }

      describe 'order of the positions' do
        before { allow(Position).to receive(:ordered).and_return(Position) }
        it 'orders the positions' do
          subject
          expect(Position).to have_received(:ordered)
        end
      end
      describe 'the return value' do
        let(:existing_positions) {
          CompaniesMembersPosition.where(
            member: confirmed_member, company: company).map(&:position)
        }
        let(:all_positions) { Position.all }
        context 'for someone who can have CompaniesMembersPositions' do
          it 'includes only positions that have not been requested/approved yet' do
            expect(subject).to contain_exactly(*all_positions - existing_positions)
          end
        end
        context 'for someone who can not have CompaniesMembersPositions' do
          before do
            allow(confirmed_member).
              to receive(:can?).with(:have, CompaniesMembersPosition).
              and_return(false)
          end
          it 'is a empty array' do
            expect(subject).to eq []
          end
        end
      end
    end
  end
end
