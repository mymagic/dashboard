require 'rails_helper'

RSpec.describe Network, type: :model do
  let(:community) { create(:community) }
  let(:network) { create(:network, community: community) }

  context 'as an adminstrator' do
    let(:member) { build(:administrator, community: community) }
    describe 'abilities' do
      subject { Ability.new(member) }

      it { is_expected.to be_able_to(:administrate, Network) }
      it { is_expected.to be_able_to(:manage, Network) }
      context 'with multiple networks' do
        it { is_expected.to be_able_to(:destroy, network) }
      end
      context 'with only one last network' do
        before do
          allow(network).to receive(:last_in_community?).and_return(true)
        end
        it { is_expected.to_not be_able_to(:destroy, network) }
      end
    end
  end

  context 'as a staff member' do
    let(:member) { build(:staff, community: community) }
    describe 'abilities' do
      subject { Ability.new(member) }

      it { is_expected.to be_able_to(:administrate, Network) }
      it { is_expected.to be_able_to(:manage, Network) }
      context 'with multiple networks' do
        it { is_expected.to be_able_to(:destroy, network) }
      end
      context 'with only one last network' do
        before do
          allow(network).to receive(:last_in_community?).and_return(true)
        end
        it { is_expected.to_not be_able_to(:destroy, network) }
      end
    end
  end

  context 'as a mentor member' do
    let(:member) { build(:mentor, community: community) }
    describe 'abilities' do
      subject { Ability.new(member) }

      it { is_expected.to_not be_able_to(:administrate, Network) }
      it { is_expected.to_not be_able_to(:manage, Network) }
    end
  end

  context 'as a regular member' do
    let(:member) { build(:member, community: community) }
    describe 'abilities' do
      subject { Ability.new(member) }

      it { is_expected.to_not be_able_to(:administrate, Network) }
      it { is_expected.to_not be_able_to(:manage, Network) }
    end
  end
end
