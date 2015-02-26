require 'rails_helper'

RSpec.describe CompaniesMembersPosition, type: :model do
  context 'validations' do
    subject { create(:companies_members_position) }

    it { is_expected.to validate_presence_of(:member) }
    it { is_expected.to validate_presence_of(:company) }
    it { is_expected.to validate_presence_of(:position) }

    context 'with a c-m-p with same company, member and position present' do
      it 'works' do
        expect {
          create(:companies_members_position, company: subject.company, position: subject.position, member: subject.member)
        }.to raise_exception(ActiveRecord::RecordNotUnique)
      end
    end
  end
end
