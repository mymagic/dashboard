require 'rails_helper'

RSpec.describe Member, type: :model do
  let(:community) { create(:community) }
  let(:network) { community.networks.first }
  let(:other_community) { create(:community) }
  let(:other_member) { create(:member, :confirmed, community: community) }
  let(:received_message) { create(:message, receiver: member, network: network) }
  let(:sent_message) { create(:message, sender: member, network: network) }
  let(:other_message) { create(:message, sender: other_member, network: network) }

  shared_examples "messaging abilities" do
    it { is_expected.to be_able_to(:send_message_to, other_member) }
    it { is_expected.to_not be_able_to(:send_message_to, member) }

    it { is_expected.to be_able_to(:create, Message) }

    it { is_expected.to be_able_to(:read, received_message) }
    it { is_expected.to be_able_to(:read, sent_message) }
    it { is_expected.to_not be_able_to(:read, other_message) }
  end


  context 'as an adminstrator' do
    let(:member) { create(:administrator, community: community) }
    describe 'abilities' do
      subject { Ability.new(member) }
      it_behaves_like "messaging abilities"
    end
  end

  context 'as a staff member' do
    let(:member) { create(:staff, community: community) }
    describe 'abilities' do
      subject { Ability.new(member) }
      it_behaves_like "messaging abilities"
    end
  end

  context 'as a mentor member' do
    let(:member) { create(:mentor, community: community) }
    describe 'abilities' do
      subject { Ability.new(member) }
      it_behaves_like "messaging abilities"
    end
  end

  context 'as regular member' do
    let(:member) { create(:member, community: community) }
    describe 'abilities' do
      subject { Ability.new(member) }
      it_behaves_like "messaging abilities"
    end
  end
end
