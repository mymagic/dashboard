require 'rails_helper'

RSpec.describe Discussion, type: :model do
  let!(:community) { create(:community) }
  let!(:network) { community.networks.first }
  let!(:other_community) { create(:community) }
  let!(:network_in_other_community) { other_community.networks.last }
  let!(:discussion_in_community) do
    create(:discussion,
           author: create(:member, community: community),
           network: network)
  end
  let!(:discussion_in_other_community) do
    create(:discussion,
           author: create(:member, community: other_community),
           network: network_in_other_community)
  end
  context 'as an adminstrator' do
    let(:member) { build(:administrator, community: community) }
    describe 'abilities' do
      subject { Ability.new(member) }

      it { is_expected.to be_able_to(:read, Discussion) }
      it { is_expected.to be_able_to(:read, discussion_in_community) }
      it { is_expected.to_not be_able_to(:read, discussion_in_other_community) }

      it { is_expected.to be_able_to(:update, Discussion) }
      it { is_expected.to be_able_to(:update, discussion_in_community) }
      it { is_expected.to_not be_able_to(:update, discussion_in_other_community) }

      it { is_expected.to be_able_to(:follow, Discussion) }
      it { is_expected.to be_able_to(:follow, discussion_in_community) }
      it { is_expected.to_not be_able_to(:follow, discussion_in_other_community) }

      it { is_expected.to be_able_to(:unfollow, Discussion) }
      it { is_expected.to be_able_to(:unfollow, discussion_in_community) }
      it { is_expected.to_not be_able_to(:unfollow, discussion_in_other_community) }

      it { is_expected.to be_able_to(:destroy, Discussion) }
      it { is_expected.to be_able_to(:destroy, discussion_in_community) }
      it { is_expected.to_not be_able_to(:destroy, discussion_in_other_community) }
    end
  end

  context 'as a staff member' do
    let(:member) { build(:staff, community: community) }
    describe 'abilities' do
      subject { Ability.new(member) }

      it { is_expected.to be_able_to(:read, Discussion) }
      it { is_expected.to be_able_to(:read, discussion_in_community) }
      it { is_expected.to_not be_able_to(:read, discussion_in_other_community) }

      it { is_expected.to be_able_to(:follow, Discussion) }
      it { is_expected.to be_able_to(:follow, discussion_in_community) }
      it { is_expected.to_not be_able_to(:follow, discussion_in_other_community) }

      it { is_expected.to be_able_to(:unfollow, Discussion) }
      it { is_expected.to be_able_to(:unfollow, discussion_in_community) }
      it { is_expected.to_not be_able_to(:unfollow, discussion_in_other_community) }

      it { is_expected.to_not be_able_to(:update, Discussion) }
      it { is_expected.to_not be_able_to(:update, discussion_in_community) }
      it { is_expected.to_not be_able_to(:update, discussion_in_other_community) }

      it { is_expected.to_not be_able_to(:destroy, Discussion) }
      it { is_expected.to_not be_able_to(:destroy, discussion_in_community) }
      it { is_expected.to_not be_able_to(:destroy, discussion_in_other_community) }
    end
  end

  context 'as a mentor member' do
    let(:member) { build(:mentor, community: community) }
    describe 'abilities' do
      subject { Ability.new(member) }

      it { is_expected.to be_able_to(:read, Discussion) }
      it { is_expected.to be_able_to(:read, discussion_in_community) }
      it { is_expected.to_not be_able_to(:read, discussion_in_other_community) }

      it { is_expected.to be_able_to(:follow, Discussion) }
      it { is_expected.to be_able_to(:follow, discussion_in_community) }
      it { is_expected.to_not be_able_to(:follow, discussion_in_other_community) }

      it { is_expected.to be_able_to(:unfollow, Discussion) }
      it { is_expected.to be_able_to(:unfollow, discussion_in_community) }
      it { is_expected.to_not be_able_to(:unfollow, discussion_in_other_community) }

      it { is_expected.to_not be_able_to(:update, Discussion) }
      it { is_expected.to_not be_able_to(:update, discussion_in_community) }
      it { is_expected.to_not be_able_to(:update, discussion_in_other_community) }

      it { is_expected.to_not be_able_to(:destroy, Discussion) }
      it { is_expected.to_not be_able_to(:destroy, discussion_in_community) }
      it { is_expected.to_not be_able_to(:destroy, discussion_in_other_community) }
    end
  end

  context 'as a regular member' do
    let(:member) { build(:member, community: community) }
    describe 'abilities' do
      subject { Ability.new(member) }

      it { is_expected.to be_able_to(:read, Discussion) }
      it { is_expected.to be_able_to(:read, discussion_in_community) }
      it { is_expected.to_not be_able_to(:read, discussion_in_other_community) }

      it { is_expected.to be_able_to(:follow, Discussion) }
      it { is_expected.to be_able_to(:follow, discussion_in_community) }
      it { is_expected.to_not be_able_to(:follow, discussion_in_other_community) }

      it { is_expected.to be_able_to(:unfollow, Discussion) }
      it { is_expected.to be_able_to(:unfollow, discussion_in_community) }
      it { is_expected.to_not be_able_to(:unfollow, discussion_in_other_community) }

      it { is_expected.to_not be_able_to(:update, Discussion) }
      it { is_expected.to_not be_able_to(:update, discussion_in_community) }
      it { is_expected.to_not be_able_to(:update, discussion_in_other_community) }

      it { is_expected.to_not be_able_to(:destroy, Discussion) }
      it { is_expected.to_not be_able_to(:destroy, discussion_in_community) }
      it { is_expected.to_not be_able_to(:destroy, discussion_in_other_community) }
    end
  end
end
