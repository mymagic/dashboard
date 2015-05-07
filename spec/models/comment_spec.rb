require 'rails_helper'

RSpec.describe Comment, type: :model do
  context 'validations' do
    subject { build(:comment) }

    it { is_expected.to validate_presence_of(:discussion) }
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_presence_of(:author) }

    it { is_expected.to belong_to(:author).class_name('Member') }
    it { is_expected.to belong_to(:discussion) }
  end

  context 'following' do
    describe 'creating a comment' do
      let!(:comment) { create(:comment) }
      it 'the author follows the discussion' do
        expect(comment.discussion.followers).to include(comment.author)
      end
    end
  end
end
