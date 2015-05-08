require 'rails_helper'

RSpec.describe Tag, type: :model do
  context 'validations' do
    subject { build(:tag, :discussion_tag) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_presence_of(:community) }
    it do
      is_expected.
        to validate_uniqueness_of(:name).scoped_to(:type, :community_id)
    end
    it { is_expected.to have_many(:taggings).dependent(:destroy) }
    it { is_expected.to belong_to(:community) }
  end

  describe '#destroy_if_orphaned!' do
    subject { tag.destroy_if_orphaned! }
    context 'with no taggings' do
      let(:tag) { create(:tag, :discussion_tag) }
      it 'should call destroy the tag' do
        expect(tag).to receive(:destroy)
        subject
      end
    end
    context 'with taggings' do
      let(:tag) { create(:tag, :discussion_tag, :with_taggings) }
      it 'should not call destroy' do
        expect(tag).to_not receive(:destroy)
        subject
      end
    end
  end
end
