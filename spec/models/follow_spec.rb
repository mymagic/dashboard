require 'rails_helper'

RSpec.describe Follow, type: :model do
  context 'validations' do
    subject { build(:follow, :discussion) }

    it { is_expected.to validate_presence_of(:member) }
    it { is_expected.to validate_presence_of(:followable) }
    it do
      is_expected.
        to validate_uniqueness_of(:followable_id).
            scoped_to(:member_id, :followable_type)
    end
    it { is_expected.to belong_to(:member) }
    it { is_expected.to belong_to(:followable) }
  end

  describe 'tyring to follow yourself' do
    let(:member) { create(:member) }
    let(:follow) { build(:follow, member: member, followable: member) }

    it 'should be invalid' do
      expect(follow).to_not be_valid
    end
  end
end
