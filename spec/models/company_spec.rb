require 'rails_helper'

RSpec.describe Company, type: :model do
  context 'validations' do
    subject { build(:company) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_length_of(:description).is_at_least(5) }
    it do
      is_expected.
        to allow_value('https://example.com', 'http://ex.com').for(:website)
    end
    it do
      is_expected.
        to_not allow_value('ht://example.com', 'ftp://ex.com').for(:website)
    end
  end

  let(:company) { create(:company, name: 'ACME Corporation') }

  describe '#to_param' do
    subject { company.to_param }
    it { is_expected.to match(/-acme-corporation/) }
  end

  context '#members' do
    let!(:community) { create(:community) }
    let!(:company) { create(:company, community: community) }
    let!(:founder) { create(:member, :confirmed, community: community) }
    let!(:team_member) { create(:member, :confirmed, community: community) }

    before do
      create(:position, founder: true, company: company, member: founder)
      create(:position, company: company, member: team_member)
    end

    describe '.founders' do
      subject { company.members.founders }
      it { is_expected.to include(founder) }
      it { is_expected.to_not include(team_member) }
    end

    describe '.team_members' do
      subject { company.members.team_members }
      it { is_expected.to include(team_member) }
      it { is_expected.to_not include(founder) }
    end
  end
end
