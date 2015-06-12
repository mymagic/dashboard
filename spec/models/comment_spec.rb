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

  context 'activitiy' do
    context 'after creating a comment' do
      let!(:comment) { create(:comment) }
      it 'created a new comment activity' do
        expect(
          Activity::Commenting.find_by(
            owner: comment.author,
            comment: comment,
            discussion: comment.discussion)
        ).to_not be_nil
      end
    end
  end
end
