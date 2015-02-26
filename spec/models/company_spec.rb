require 'rails_helper'

RSpec.describe Company, type: :model do
  context 'validations' do
    subject { build(:company) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:description).is_at_least(5) }
    it { is_expected.to allow_value('https://example.com', 'http://example.com').for(:website) }
    it { is_expected.to_not allow_value('ht://example.com', 'ftp://example.com').for(:website) }

    it { is_expected.to have_many(:members_positions).class_name('CompaniesMembersPosition').dependent(:destroy).inverse_of(:company) }
    it { is_expected.to have_many(:positions).through(:members_positions).conditions(:uniq) }
    it { is_expected.to have_many(:members).through(:members_positions) }

    it { is_expected.to have_many(:approved_members_positions).class_name('CompaniesMembersPosition').conditions(approved: true).dependent(:destroy) }
    it { is_expected.to have_many(:approved_positions).through(:approved_members_positions).conditions(:uniq).source(:position) }
    it { is_expected.to have_many(:approved_members).through(:approved_members_positions).source(:member) }
  end

  let(:company) { create(:company, name: 'ACME Corporation') }

  describe '#to_param' do
    subject { company.to_param }
    it { is_expected.to match(/-acme-corporation/) }
  end

  describe '#approved_positions_and_members' do
    context 'as a new company' do
      subject { company.approved_positions_and_members }
      it { is_expected.to be_empty }
    end
  end
end
