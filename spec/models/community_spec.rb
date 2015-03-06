require 'rails_helper'

RSpec.describe Community, type: :model do
  context 'validations' do
    subject { FactoryGirl.create(:community) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_uniqueness_of(:slug) }
  end

  context 'callbacks' do
    it 'create default administrator' do
      expect {
        FactoryGirl.create(:community)
      }.to change { Member.where(role: 'administrator').count }.by(1)
    end
  end
end
