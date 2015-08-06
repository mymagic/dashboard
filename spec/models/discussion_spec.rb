require 'rails_helper'

RSpec.describe Discussion, type: :model do
  let(:network) { create(:community).default_network }
  context 'validations' do
    subject { build(:discussion) }

    it { is_expected.to validate_presence_of(:title) }
    it { is_expected.to validate_presence_of(:body) }
    it { is_expected.to validate_presence_of(:author) }

    it { is_expected.to belong_to(:author).class_name('Member') }
    it { is_expected.to belong_to(:network) }
  end

  context 'following' do
    describe 'creating a discussion' do
      let!(:discussion) { create(:discussion, network: network) }
      it 'the author follows the discussion' do
        expect(discussion.followers).to include(discussion.author)
      end
    end
  end

  context 'tagging' do
    subject { create(:discussion, network: network) }
    it_behaves_like 'taggable'
  end

  context 'followable' do
    subject(:followable) { create(:discussion, network: network) }
    it_behaves_like 'followable'
  end

  context 'activitiy' do
    context 'after creating a discussion' do
      let!(:discussion) { create(:discussion, network: network) }
      it 'created a new discussion activity' do
        expect(
          Activity::Discussing.find_by(
            owner: discussion.author,
            discussion: discussion)
        ).to_not be_nil
      end
    end
  end
end
