require 'rails_helper'

RSpec.describe Discussion, type: :model do
  context 'validations' do
    subject { build(:discussion) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_presence_of(:author) }

    it { is_expected.to belong_to(:author).class_name('Member') }
    it { is_expected.to belong_to(:community) }
  end

  context 'following' do
    describe 'creating a discussion' do
      let!(:discussion) { create(:discussion) }
      it 'the author follows the discussion' do
        expect(discussion.followers).to include(discussion.author)
      end
    end
  end
end
