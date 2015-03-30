require 'rails_helper'

RSpec.describe Member, type: :model do
  let(:company) { create(:company) }
  let(:other_company) { create(:company) }
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

      # Community
      it { is_expected.to be_able_to(:manage, Community) }

      # Company
      it { is_expected.to be_able_to(:read, Company) }

      # Company Member management
      it { is_expected.to be_able_to(:invite_company_member, company) }
      it { is_expected.to be_able_to(:invite_company_member, other_company) }

      # OfficeHour
      it { is_expected.to be_able_to(:read, OfficeHour) }

      # SocialMediaLink
      it { is_expected.to be_able_to(:manage, SocialMediaLink) }

      # CompaniesMembersPosition
      it { is_expected.to be_able_to(:have, CompaniesMembersPosition) }
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

      # Community
      it { is_expected.to be_able_to(:read, Community) }

      # Company
      it { is_expected.to be_able_to(:read, Company) }

      # Company Member management
      it { is_expected.to be_able_to(:invite_company_member, company) }
      it { is_expected.to be_able_to(:invite_company_member, other_company) }

      # OfficeHour
      it { is_expected.to be_able_to(:read, OfficeHour) }

      # SocialMediaLink
      it { is_expected.to be_able_to(:manage, FactoryGirl.build(:social_media_link, attachable: member)) }
      it { is_expected.to_not be_able_to(:manage, FactoryGirl.build(:social_media_link, :member)) }

      # CompaniesMembersPosition
      it { is_expected.to be_able_to(:have, CompaniesMembersPosition) }
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

      # Community
      it { is_expected.to be_able_to(:read, Community) }

      # Company
      it { is_expected.to be_able_to(:read, Company) }

      # Company Member management
      it { is_expected.to_not be_able_to(:invite_company_member, company) }
      it { is_expected.to_not be_able_to(:invite_company_member, other_company) }

      # OfficeHour
      it { is_expected.to be_able_to(:read, OfficeHour) }

      # SocialMediaLink
      it { is_expected.to be_able_to(:manage, FactoryGirl.build(:social_media_link, attachable: member)) }
      it { is_expected.to_not be_able_to(:manage, FactoryGirl.build(:social_media_link, :member)) }

      # CompaniesMembersPosition
      it { is_expected.to_not be_able_to(:have, CompaniesMembersPosition) }
    end
  end

  context 'as regular member' do
    let(:member) { build(:member) }
    let(:new_member) { build(:member) }
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
      it { is_expected.to_not be_able_to(:create, new_member) }
      it { is_expected.to_not be_able_to(:update, Member) }
      it { is_expected.to_not be_able_to(:destroy, Member) }
      it { is_expected.to_not be_able_to(:resend_invitation, Member) }

      # Community
      it { is_expected.to be_able_to(:read, Community) }

      # Company
      it { is_expected.to be_able_to(:read, Company) }

      # Company Member management
      it { is_expected.to_not be_able_to(:invite_company_member, company) }
      it { is_expected.to_not be_able_to(:invite_company_member, other_company) }

      # OfficeHour
      it { is_expected.to be_able_to(:read, OfficeHour) }

      # SocialMediaLink
      it { is_expected.to be_able_to(:manage, FactoryGirl.build(:social_media_link, attachable: member)) }
      it { is_expected.to_not be_able_to(:manage, FactoryGirl.build(:social_media_link, :member)) }

      # CompaniesMembersPosition
      it { is_expected.to be_able_to(:have, CompaniesMembersPosition) }
    end
  end

  context 'as regular member who is a manager' do
    let(:community) { create(:community) }
    let(:member) { create(:member, community: community) }
    let(:position) { create(:position, community: community) }
    let(:new_member_for_company) { build(:member, community: community) }
    let(:new_member_for_other_company) { build(:member, community: community) }
    before do
      CompaniesMembersPosition.create(
        position: position,
        member: member,
        company: company,
        approved: true,
        can_manage_company: true
      )
      new_member_for_company.companies_positions = []
      new_member_for_company.
        companies_positions.
        build(company: company, position: position, approved: true)
    end

    describe 'abilities' do
      subject { Ability.new(member) }

      # Member management
      it { is_expected.to be_able_to(:create, new_member_for_company) }
      it { is_expected.to_not be_able_to(:create, new_member_for_other_company) }

      # Company Member management
      it { is_expected.to be_able_to(:invite_company_member, company) }
      it { is_expected.to_not be_able_to(:invite_company_member, other_company) }
    end
  end
end
