require 'rails_helper'

RSpec.describe Member, type: :model do
  context 'validations' do
    subject { build(:member) }

    it { is_expected.to validate_presence_of(:first_name) }
    it { is_expected.to validate_presence_of(:last_name) }
    it { is_expected.to validate_presence_of(:time_zone) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
    it { is_expected.to validate_confirmation_of(:password) }

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

  let(:member) { create(:member, first_name: 'Harry', last_name: 'Houdini') }
  let(:administrator) { create(:administrator) }

  describe '::ROLES' do
    subject { Member::ROLES }
    it { is_expected.to include(:administrator) }
    it { is_expected.to include(:staff) }
    it { is_expected.to include(:mentor) }
  end

  describe '#administrator?' do
    context 'as a regular member' do
      subject { member.administrator? }
      it { is_expected.to be_falsy }
    end
    context 'an administrator' do
      subject { administrator.administrator? }
      it { is_expected.to be_truthy }
    end
  end

  describe '#full_name' do
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
