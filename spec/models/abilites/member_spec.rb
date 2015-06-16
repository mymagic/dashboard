require 'rails_helper'

RSpec.describe Member, type: :model do
  let(:community) { create(:community) }
  let(:other_community) { create(:community) }
  let(:company) { create(:company, community: community) }
  let(:other_company) { create(:company, community: community) }
  context 'as an adminstrator' do
    let(:member) { build(:administrator, community: community) }
    describe 'abilities' do
      subject { Ability.new(member) }
      # Administration
      it { is_expected.to be_able_to(:administrate, :application) }
      it { is_expected.to be_able_to(:administrate, Community) }
      it { is_expected.to be_able_to(:administrate, Company) }
      it { is_expected.to be_able_to(:administrate, Member) }

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

      # Community
      it { is_expected.to be_able_to(:manage, community) }
      it { is_expected.to_not be_able_to(:manage, other_community) }

      # Company
      it { is_expected.to be_able_to(:read, Company) }

      # Company Member management
      it { is_expected.to be_able_to(:invite_company_member, company) }
      it { is_expected.to be_able_to(:invite_company_member, other_company) }
      it { is_expected.to be_able_to(:update, company) }
      it { is_expected.to be_able_to(:update, other_company) }

      # SocialMediaLink
      it { is_expected.to be_able_to(:manage, SocialMediaLink) }

      # Availability
      it { is_expected.to be_able_to(:read, FactoryGirl.build(:availability)) }
      it { is_expected.to be_able_to(:manage, FactoryGirl.build(:availability, member: member)) }
      it { is_expected.to_not be_able_to(:manage, FactoryGirl.build(:availability)) }

      # Slot
      it { is_expected.to be_able_to(:read, Slot) }
      it { is_expected.to be_able_to(:update, Slot) }
      it { is_expected.to be_able_to(:destroy, Slot) }

      # Calendar
      it { is_expected.to be_able_to(:manage, :calendar) }

      # Position
      it { is_expected.to be_able_to(:have, Position) }
      it { is_expected.to be_able_to(:read, Position) }
      it { is_expected.to be_able_to(:manage_members_positions, company) }
      it { is_expected.to be_able_to(:manage_members_positions, other_company) }
    end
  end

  context 'as a staff member' do
    let(:member) { build(:staff, community: community) }
    describe 'abilities' do
      subject { Ability.new(member) }
      # Administration
      it { is_expected.to be_able_to(:administrate, :application) }
      it { is_expected.to_not be_able_to(:administrate, Community) }
      it { is_expected.to be_able_to(:administrate, Company) }
      it { is_expected.to be_able_to(:administrate, Member) }

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

      # Community
      it { is_expected.to be_able_to(:read, Community) }
      it { is_expected.to_not be_able_to(:manage, community) }

      # Company
      it { is_expected.to be_able_to(:read, Company) }
      it { is_expected.to be_able_to(:update, Company) }
      it { is_expected.to_not be_able_to(:destroy, Company) }

      # Company Member management
      it { is_expected.to be_able_to(:invite_company_member, company) }
      it { is_expected.to be_able_to(:invite_company_member, other_company) }
      it { is_expected.to be_able_to(:update, company) }
      it { is_expected.to be_able_to(:update, other_company) }

      # SocialMediaLink
      it { is_expected.to be_able_to(:manage, FactoryGirl.build(:social_media_link, attachable: member)) }
      it { is_expected.to_not be_able_to(:manage, FactoryGirl.build(:social_media_link, :member)) }

      # Availability
      it { is_expected.to be_able_to(:read, FactoryGirl.build(:availability)) }
      it { is_expected.to be_able_to(:manage, FactoryGirl.build(:availability, member: member)) }
      it { is_expected.to_not be_able_to(:manage, FactoryGirl.build(:availability)) }

      # Slot
      it { is_expected.to be_able_to(:read, Slot) }
      it { is_expected.to be_able_to(:update, FactoryGirl.build(:slot, member: member)) }
      it { is_expected.to be_able_to(:destroy, FactoryGirl.build(:slot, member: member)) }
      it { is_expected.to be_able_to(:create, FactoryGirl.build(:slot)) }

      # Calendar
      it { is_expected.to be_able_to(:read, :calendar) }

      # Position
      it { is_expected.to be_able_to(:have, Position) }
      it { is_expected.to be_able_to(:read, Position) }
      it { is_expected.to be_able_to(:manage_members_positions, company) }
      it { is_expected.to be_able_to(:manage_members_positions, other_company) }
    end
  end

  context 'as a mentor member' do
    let(:member) { build(:mentor, community: community) }
    describe 'abilities' do
      subject { Ability.new(member) }
      # Administration
      it { is_expected.to_not be_able_to(:administrate, :application) }
      it { is_expected.to_not be_able_to(:administrate, Community) }
      it { is_expected.to_not be_able_to(:administrate, Company) }
      it { is_expected.to_not be_able_to(:administrate, Member) }

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

      # Community
      it { is_expected.to be_able_to(:read, Community) }
      it { is_expected.to_not be_able_to(:manage, community) }

      # Company
      it { is_expected.to be_able_to(:read, Company) }

      # Company Member management
      it { is_expected.to_not be_able_to(:invite_company_member, company) }
      it { is_expected.to_not be_able_to(:invite_company_member, other_company) }

      # SocialMediaLink
      it { is_expected.to be_able_to(:manage, FactoryGirl.build(:social_media_link, attachable: member)) }
      it { is_expected.to_not be_able_to(:manage, FactoryGirl.build(:social_media_link, :member)) }

      # Availability
      it { is_expected.to be_able_to(:read, FactoryGirl.build(:availability)) }
      it { is_expected.to be_able_to(:manage, FactoryGirl.build(:availability, member: member)) }
      it { is_expected.to_not be_able_to(:manage, FactoryGirl.build(:availability)) }

      # Slot
      it { is_expected.to be_able_to(:read, Slot) }
      it { is_expected.to be_able_to(:update, FactoryGirl.build(:slot, member: member)) }
      it { is_expected.to be_able_to(:destroy, FactoryGirl.build(:slot, member: member)) }
      it { is_expected.to be_able_to(:create, FactoryGirl.build(:slot)) }

      # Calendar
      it { is_expected.to be_able_to(:read, :calendar) }

      # Position
      it { is_expected.to_not be_able_to(:have, Position) }
      it { is_expected.to_not be_able_to(:read, Position) }
      it { is_expected.to_not be_able_to(:manage_members_positions, company) }
      it { is_expected.to_not be_able_to(:manage_members_positions, other_company) }
    end
  end

  context 'as regular member' do
    let(:member) { build(:member, community: community) }
    let(:new_member) { build(:member, community: community) }
    describe 'abilities' do
      subject { Ability.new(member) }
      # Administration
      it { is_expected.to_not be_able_to(:administrate, :application) }
      it { is_expected.to_not be_able_to(:administrate, Community) }
      it { is_expected.to_not be_able_to(:administrate, Company) }
      it { is_expected.to_not be_able_to(:administrate, Member) }

      # Invitations
      it { is_expected.to_not be_able_to(:invite_administrator, :members) }
      it { is_expected.to_not be_able_to(:invite_staff, :members) }
      it { is_expected.to_not be_able_to(:invite_mentor, :members) }
      it { is_expected.to_not be_able_to(:invite_regular_member, :members) }

      # Member management
      it { is_expected.to be_able_to(:read, Member) }
      it { is_expected.to_not be_able_to(:create, new_member) }
      it { is_expected.to_not be_able_to(:update, Member) }
      it { is_expected.to_not be_able_to(:destroy, Member) }
      it { is_expected.to_not be_able_to(:resend_invitation, Member) }

      # Community
      it { is_expected.to be_able_to(:read, Community) }
      it { is_expected.to_not be_able_to(:manage, community) }

      # Company
      it { is_expected.to be_able_to(:read, Company) }

      # Company Member management
      it { is_expected.to_not be_able_to(:invite_company_member, company) }
      it { is_expected.to_not be_able_to(:invite_company_member, other_company) }
      it { is_expected.to_not be_able_to(:update, company) }
      it { is_expected.to_not be_able_to(:update, other_company) }

      # SocialMediaLink
      it { is_expected.to be_able_to(:manage, FactoryGirl.build(:social_media_link, attachable: member)) }
      it { is_expected.to_not be_able_to(:manage, FactoryGirl.build(:social_media_link, :member)) }

      # Availability
      it { is_expected.to be_able_to(:read, FactoryGirl.build(:availability)) }
      it { is_expected.to be_able_to(:manage, FactoryGirl.build(:availability, member: member)) }
      it { is_expected.to_not be_able_to(:manage, FactoryGirl.build(:availability)) }

      # Slot
      it { is_expected.to be_able_to(:read, Slot) }
      it { is_expected.to be_able_to(:update, FactoryGirl.build(:slot, member: member)) }
      it { is_expected.to be_able_to(:destroy, FactoryGirl.build(:slot, member: member)) }
      it { is_expected.to be_able_to(:create, FactoryGirl.build(:slot)) }

      # Calendar
      it { is_expected.to be_able_to(:read, :calendar) }

      # Position
      it { is_expected.to be_able_to(:have, Position) }
      it { is_expected.to_not be_able_to(:read, Position) }
      it { is_expected.to_not be_able_to(:manage_members_positions, company) }
      it { is_expected.to_not be_able_to(:manage_members_positions, other_company) }
    end
  end

  context 'as regular member who is a manager' do
    let(:member) { create(:member, community: community) }
    let(:new_member_for_company) { build(:member, community: community) }
    let(:new_member_for_other_company) { build(:member, community: community) }
    before do
      create(:position, founder: true, member: member, company: company)
      new_member_for_company.positions = []
      new_member_for_company.positions.build(company: company)
    end

    describe 'abilities' do
      subject { Ability.new(member) }

      # Member management
      it { is_expected.to be_able_to(:create, new_member_for_company) }
      it { is_expected.to_not be_able_to(:create, new_member_for_other_company) }

      # Company management
      it { is_expected.to be_able_to(:manage_company, company) }
      it { is_expected.to_not be_able_to(:manage_company, other_company) }
      it { is_expected.to be_able_to(:update, company) }
      it { is_expected.to_not be_able_to(:update, other_company) }

      # Company Member management
      it { is_expected.to be_able_to(:invite_company_member, company) }
      it { is_expected.to_not be_able_to(:invite_company_member, other_company) }

      # Company Member Position mangement
      it { is_expected.to be_able_to(:manage_members_positions, company) }
      it { is_expected.to_not be_able_to(:manage_members_positions, other_company) }
    end
  end
end
