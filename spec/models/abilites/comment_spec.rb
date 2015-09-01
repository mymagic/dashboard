require 'rails_helper'

RSpec.describe Comment, type: :model do
  let(:community) { create(:community) }
  let(:other_community) { create(:community) }
  let(:comment_in_community) do
    build(:comment,
          author: create(:author, :confirmed, community: community))
  end
  let(:comment_in_other_community) do
    build(:comment,
          author: create(:author, :confirmed, community: other_community))
  end
  let(:his_own_comment) { build(:comment, author: member) }

  context 'as an adminstrator' do
    let(:member) { build(:administrator, community: community) }
    describe 'abilities' do
      subject { Ability.new(member) }

      it { is_expected.to be_able_to(:create, Comment) }
      it { is_expected.to be_able_to(:create, comment_in_community) }
      it { is_expected.to_not be_able_to(:create, comment_in_other_community) }

      it { is_expected.to be_able_to(:destroy, Comment) }
      it { is_expected.to be_able_to(:destroy, comment_in_community) }
      it { is_expected.to_not be_able_to(:destroy, comment_in_other_community) }
    end
  end

  context 'as a staff member' do
    let(:member) { build(:staff, community: community) }
    describe 'abilities' do
      subject { Ability.new(member) }

      it { is_expected.to be_able_to(:create, Comment) }
      it { is_expected.to be_able_to(:create, comment_in_community) }
      it { is_expected.to_not be_able_to(:create, comment_in_other_community) }

      it { is_expected.to be_able_to(:destroy, his_own_comment) }
      it { is_expected.to_not be_able_to(:destroy, comment_in_community) }
      it { is_expected.to_not be_able_to(:destroy, comment_in_other_community) }

      it { is_expected.to be_able_to(:update, his_own_comment) }
      it { is_expected.to_not be_able_to(:update, comment_in_community) }
      it { is_expected.to_not be_able_to(:update, comment_in_other_community) }
    end
  end

  context 'as a mentor member' do
    let(:member) { build(:mentor, community: community) }
    describe 'abilities' do
      subject { Ability.new(member) }

      it { is_expected.to be_able_to(:create, Comment) }
      it { is_expected.to be_able_to(:create, comment_in_community) }
      it { is_expected.to_not be_able_to(:create, comment_in_other_community) }

      it { is_expected.to be_able_to(:destroy, his_own_comment) }
      it { is_expected.to_not be_able_to(:destroy, comment_in_community) }
      it { is_expected.to_not be_able_to(:destroy, comment_in_other_community) }

      it { is_expected.to be_able_to(:update, his_own_comment) }
      it { is_expected.to_not be_able_to(:update, comment_in_community) }
      it { is_expected.to_not be_able_to(:update, comment_in_other_community) }
    end
  end

  context 'as a regular member' do
    let(:member) { build(:member, community: community) }
    describe 'abilities' do
      subject { Ability.new(member) }

      it { is_expected.to be_able_to(:create, Comment) }
      it { is_expected.to be_able_to(:create, comment_in_community) }
      it { is_expected.to_not be_able_to(:create, comment_in_other_community) }

      it { is_expected.to be_able_to(:destroy, his_own_comment) }
      it { is_expected.to_not be_able_to(:destroy, comment_in_community) }
      it { is_expected.to_not be_able_to(:destroy, comment_in_other_community) }

      it { is_expected.to be_able_to(:update, his_own_comment) }
      it { is_expected.to_not be_able_to(:update, comment_in_community) }
      it { is_expected.to_not be_able_to(:update, comment_in_other_community) }
    end
  end
end
