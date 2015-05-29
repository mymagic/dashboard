require 'rails_helper'

RSpec.describe Member, type: :model do
  context 'validations' do
    subject { build(:member) }

    it { is_expected.to validate_presence_of(:first_name).on(:update) }
    it { is_expected.to validate_presence_of(:last_name).on(:update) }
    it { is_expected.to validate_presence_of(:time_zone).on(:update) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).scoped_to(:community_id) }
    it { is_expected.to validate_confirmation_of(:password) }
    it { is_expected.to validate_inclusion_of(:role).in_array(Member::ROLES.map(&:to_s)).allow_blank(true) }

    it { is_expected.to have_many(:companies_positions).class_name('CompaniesMembersPosition').dependent(:destroy).inverse_of(:member) }
  end

  let(:mentor) { create(:mentor) }
  let(:member) { create(:member) }
  let(:staff)  { create(:staff) }
  let(:administrator) { create(:administrator) }

  context 'roles' do
    describe '::ROLES' do
      subject { Member::ROLES }
      it { is_expected.to include(:mentor) }
      it { is_expected.to include(:staff) }
      it { is_expected.to include(:administrator) }
    end

    describe '#administrator?' do
      subject { member_object.administrator? }
      context 'as a mentor' do
        let(:member_object) { mentor }
        it { is_expected.to be_falsy }
      end
      context 'as a member' do
        let(:member_object) { member }
        it { is_expected.to be_falsy }
      end
      context 'as staff' do
        let(:member_object) { staff }
        it { is_expected.to be_falsy }
      end
      context 'as a administrator' do
        let(:member_object) { administrator }
        it { is_expected.to be_truthy }
      end
    end

    describe '#staff?' do
      subject { member_object.staff? }
      context 'as a mentor' do
        let(:member_object) { mentor }
        it { is_expected.to be_falsy }
      end
      context 'as a member' do
        let(:member_object) { member }
        it { is_expected.to be_falsy }
      end
      context 'as staff' do
        let(:member_object) { staff }
        it { is_expected.to be_truthy }
      end
      context 'as a administrator' do
        let(:member_object) { administrator }
        it { is_expected.to be_falsy }
      end
    end

    describe '#mentor?' do
      subject { member_object.mentor? }
      context 'as a mentor' do
        let(:member_object) { mentor }
        it { is_expected.to be_truthy }
      end
      context 'as a member' do
        let(:member_object) { member }
        it { is_expected.to be_falsy }
      end
      context 'as staff' do
        let(:member_object) { staff }
        it { is_expected.to be_falsy }
      end
      context 'as a administrator' do
        let(:member_object) { administrator }
        it { is_expected.to be_falsy }
      end
    end

    describe '#regular_member?' do
      subject { member_object.regular_member? }
      context 'as a mentor' do
        let(:member_object) { mentor }
        it { is_expected.to be_falsy }
      end
      context 'as a member' do
        let(:member_object) { member }
        it { is_expected.to be_truthy }
      end
      context 'as staff' do
        let(:member_object) { staff }
        it { is_expected.to be_falsy }
      end
      context 'as a administrator' do
        let(:member_object) { administrator }
        it { is_expected.to be_falsy }
      end
    end
  end

  describe '#full_name' do
    before do
      member.first_name = 'Harry'
      member.last_name  = 'Houdini'
    end
    subject { member.full_name }
    it { is_expected.to eq 'Harry Houdini' }
  end

  describe '#positions_in_companies' do
    context 'as a new member' do
      subject { member.positions_in_companies }
      it { is_expected.to_not be_empty }
    end
  end

  context 'Messages' do
    let(:community) { create(:community) }
    let(:member1) { create(:member, community: community) }
    let(:member2) { create(:member, community: community)}
    let(:participant) { create(:member, community: community) }
    let!(:send_message) { create(:message, sender: member1, receiver: participant) }
    let!(:received_message) { create(:message, sender: participant, receiver: member1) }
    let!(:other_message) { create(:message) }

    describe '#messages_with' do
      subject { member1.messages_with(participant) }

      it { is_expected.to include(send_message, received_message) }
      it { is_expected.to_not include(other_message) }
    end

    describe '#last_chat_participant' do
      context 'with participant' do
        subject { member1.last_chat_participant }

        it { is_expected.to eq(participant) }
      end

      context 'without participant' do
        subject { member2.last_chat_participant }

        it { is_expected.to be_nil }
      end
    end
  end
end
