require 'rails_helper'

RSpec.describe Member, type: :model do
  context 'as an adminstrator' do
    let(:member) { build(:administrator) }
    describe 'abilities' do
      subject { Ability.new(member) }
      it { is_expected.to be_able_to(:administrate, :application) }
    end
  end

  context 'as a staff member' do
    let(:member) { build(:staff) }
    describe 'abilities' do
      subject { Ability.new(member) }
      it { is_expected.to_not be_able_to(:administrate, :application) }
    end
  end

  context 'as a mentor member' do
    let(:member) { build(:mentor) }
    describe 'abilities' do
      subject { Ability.new(member) }
      it { is_expected.to_not be_able_to(:administrate, :application) }
    end
  end

  context 'as regular member' do
    let(:member) { build(:member) }
    describe 'abilities' do
      subject { Ability.new(member) }
      it { is_expected.to_not be_able_to(:administrate, :application) }
    end
  end
end
