require 'rails_helper'

RSpec.describe Member, type: :model do
  context 'as an adminstrator' do
    let(:member) { build(:administrator) }
    describe 'abilities' do
      subject { Ability.new(member) }
      # Administration
      it { is_expected.to be_able_to(:administrate, :application) }
      it { is_expected.to be_able_to(:administrate, Member) }
      it { is_expected.to be_able_to(:administrate, Position) }
      it { is_expected.to be_able_to(:administrate, Company) }
      it { is_expected.to be_able_to(:administrate, OfficeHour) }

      # Invitations
      it { is_expected.to be_able_to(:invite_administrator, :members) }
      it { is_expected.to be_able_to(:invite_staff, :members) }
      it { is_expected.to be_able_to(:invite_mentor, :members) }
      it { is_expected.to be_able_to(:invite_regular_member, :members) }

      # Member management
      it { is_expected.to be_able_to(:read, Member) }
      it { is_expected.to be_able_to(:create, Member) }
      it { is_expected.to be_able_to(:update, Member, role: ['administrator', 'staff', 'mentor', '']) }
      it { is_expected.to be_able_to(:destroy, Member, role: ['administrator', 'staff', 'mentor', '']) }
      it { is_expected.to be_able_to(:resend_invitation, Member) }

      # Company
      it { is_expected.to be_able_to(:read, Company) }

      # OfficeHour
      it { is_expected.to be_able_to(:read, OfficeHour) }
    end
  end

  context 'as a staff member' do
    let(:member) { build(:staff) }
    describe 'abilities' do
      subject { Ability.new(member) }
      # Administration
      it { is_expected.to be_able_to(:administrate, :application) }
      it { is_expected.to be_able_to(:administrate, Member) }
      it { is_expected.to_not be_able_to(:administrate, Position) }
      it { is_expected.to_not be_able_to(:administrate, Company) }
      it { is_expected.to_not be_able_to(:administrate, OfficeHour) }

      # Invitations
      it { is_expected.to_not be_able_to(:invite_administrator, :members) }
      it { is_expected.to_not be_able_to(:invite_staff, :members) }
      it { is_expected.to be_able_to(:invite_mentor, :members) }
      it { is_expected.to be_able_to(:invite_regular_member, :members) }

      # Member management
      it { is_expected.to be_able_to(:read, Member) }
      it { is_expected.to be_able_to(:create, Member) }
      it { is_expected.to be_able_to(:update, Member, role: ['mentor', '']) }
      it { is_expected.to be_able_to(:destroy, Member, role: ['mentor', '']) }
      it { is_expected.to be_able_to(:resend_invitation, Member) }

      # Company
      it { is_expected.to be_able_to(:read, Company) }

      # OfficeHour
      it { is_expected.to be_able_to(:read, OfficeHour) }
    end
  end

  context 'as a mentor member' do
    let(:member) { build(:mentor) }
    describe 'abilities' do
      subject { Ability.new(member) }
      # Administration
      it { is_expected.to_not be_able_to(:administrate, :application) }
      it { is_expected.to_not be_able_to(:administrate, Member) }
      it { is_expected.to_not be_able_to(:administrate, Position) }
      it { is_expected.to_not be_able_to(:administrate, Company) }
      it { is_expected.to_not be_able_to(:administrate, OfficeHour) }

      # Invitations
      it { is_expected.to_not be_able_to(:invite_administrator, :members) }
      it { is_expected.to_not be_able_to(:invite_staff, :members) }
      it { is_expected.to_not be_able_to(:invite_mentor, :members) }
      it { is_expected.to_not be_able_to(:invite_regular_member, :members) }

      # Member management
      it { is_expected.to be_able_to(:read, Member) }
      it { is_expected.to_not be_able_to(:create, Member) }
      it { is_expected.to_not be_able_to(:update, Member) }
      it { is_expected.to_not be_able_to(:destroy, Member) }
      it { is_expected.to_not be_able_to(:resend_invitation, Member) }

      # Company
      it { is_expected.to be_able_to(:read, Company) }

      # OfficeHour
      it { is_expected.to be_able_to(:read, OfficeHour) }
    end
  end

  context 'as regular member' do
    let(:member) { build(:member) }
    describe 'abilities' do
      subject { Ability.new(member) }
      # Administration
      it { is_expected.to_not be_able_to(:administrate, :application) }
      it { is_expected.to_not be_able_to(:administrate, Member) }
      it { is_expected.to_not be_able_to(:administrate, Position) }
      it { is_expected.to_not be_able_to(:administrate, Company) }
      it { is_expected.to_not be_able_to(:administrate, OfficeHour) }

      # Invitations
      it { is_expected.to_not be_able_to(:invite_administrator, :members) }
      it { is_expected.to_not be_able_to(:invite_staff, :members) }
      it { is_expected.to_not be_able_to(:invite_mentor, :members) }
      it { is_expected.to_not be_able_to(:invite_regular_member, :members) }

      # Member management
      it { is_expected.to be_able_to(:read, Member) }
      it { is_expected.to_not be_able_to(:create, Member) }
      it { is_expected.to_not be_able_to(:update, Member) }
      it { is_expected.to_not be_able_to(:destroy, Member) }
      it { is_expected.to_not be_able_to(:resend_invitation, Member) }

      # Company
      it { is_expected.to be_able_to(:read, Company) }

      # OfficeHour
      it { is_expected.to be_able_to(:read, OfficeHour) }
    end
  end
end
