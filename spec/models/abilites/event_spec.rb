require 'rails_helper'

RSpec.describe Event, type: :model do
  let(:community) { create(:community) }
  let(:event) { create(:event, creator(:administrator, community: community)) }

  context 'as an adminstrator' do
    let(:member) { build(:administrator, community: community) }
    describe 'abilities' do
      subject { Ability.new(member) }

      it { is_expected.to be_able_to(:create, Event) }
      it { is_expected.to be_able_to(:read, Event) }
      it { is_expected.to be_able_to(:update, Event) }
      it { is_expected.to be_able_to(:destroy, Event) }
    end
  end

  context 'as a staff member' do
    let(:member) { build(:staff, community: community) }
    describe 'abilities' do
      subject { Ability.new(member) }

      it { is_expected.to be_able_to(:create, Event) }
      it { is_expected.to be_able_to(:read, Event) }
      it { is_expected.to be_able_to(:update, Event) }
      it { is_expected.to be_able_to(:destroy, Event) }
    end
  end

  context 'as a mentor member' do
    let(:member) { build(:mentor, community: community) }
    describe 'abilities' do
      subject { Ability.new(member) }

      it { is_expected.to_not be_able_to(:create, Event) }
      it { is_expected.to be_able_to(:read, Event) }
      it { is_expected.to_not be_able_to(:update, Event) }
      it { is_expected.to_not be_able_to(:destroy, Event) }
    end
  end

  context 'as a regular member' do
    let(:member) { build(:member, community: community) }
    describe 'abilities' do
      subject { Ability.new(member) }

      it { is_expected.to_not be_able_to(:create, Event) }
      it { is_expected.to be_able_to(:read, Event) }
      it { is_expected.to_not be_able_to(:update, Event) }
      it { is_expected.to_not be_able_to(:destroy, Event) }
    end
  end
end
