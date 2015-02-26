require 'rails_helper'

RSpec.describe Member, type: :model do
  context 'validations' do
    subject { build(:member) }

    it { is_expected.to validate_presence_of(:first_name).on(:update) }
    it { is_expected.to validate_presence_of(:last_name).on(:update) }
    it { is_expected.to validate_presence_of(:time_zone).on(:update) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
    it { is_expected.to validate_confirmation_of(:password) }
    it { is_expected.to validate_inclusion_of(:role).in_array(Member::ROLES.map(&:to_s)).allow_blank(true) }

    it { is_expected.to have_many(:companies_positions).class_name('CompaniesMembersPosition').dependent(:destroy).inverse_of(:member) }
    it { is_expected.to have_many(:companies).through(:companies_positions).conditions(:uniq) }
    it { is_expected.to have_many(:positions).through(:companies_positions) }

    it { is_expected.to have_many(:approved_companies_positions).class_name('CompaniesMembersPosition').conditions(approved: true).dependent(:destroy) }
    it { is_expected.to have_many(:approved_positions).through(:approved_companies_positions) }
    it { is_expected.to have_many(:approved_companies).through(:approved_companies_positions).conditions(:uniq) }
    it { is_expected.to accept_nested_attributes_for(:companies_positions).allow_destroy(true) }

    it { is_expected.to have_many(:office_hours_as_participant).class_name('OfficeHour').with_foreign_key(:participant_id) }
    it { is_expected.to have_many(:office_hours_as_mentor).class_name('OfficeHour').with_foreign_key(:mentor_id) }
    it { is_expected.to accept_nested_attributes_for(:office_hours_as_mentor) }
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

  describe '#approved_companies_and_positions' do
    context 'as a new member' do
      subject { member.approved_companies_and_positions }
      it { is_expected.to be_empty }
    end
  end
end
