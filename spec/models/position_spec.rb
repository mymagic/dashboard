require 'rails_helper'

RSpec.describe Position, type: :model do
  context 'validations' do
    subject { build(:position) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }

    it { is_expected.to have_many(:companies_members).class_name('CompaniesMembersPosition').dependent(:destroy).inverse_of(:position) }
    it { is_expected.to have_many(:companies).through(:companies_members).conditions(:uniq) }
    it { is_expected.to have_many(:members).through(:companies_members).conditions(:uniq) }
  end
end
