require 'rails_helper'

RSpec.describe CompaniesMembersPosition, type: :model do
  context 'validations' do
    subject { build(:companies_members_position) }

    it { is_expected.to validate_presence_of(:member) }
    it { is_expected.to validate_presence_of(:company) }
    it { is_expected.to validate_presence_of(:position) }

    context 'with a c-m-p with same company, member and position present' do
      before do
        create(:companies_members_position,
               position: subject.position,
               company: subject.company,
               member: subject.member)
      end
      it { is_expected.to be_invalid }
    end
  end
end
