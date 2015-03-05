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
    context 'as a new company' do
      subject { company.positions_with_members }
      it { is_expected.to be_empty }
    end
  end
end
