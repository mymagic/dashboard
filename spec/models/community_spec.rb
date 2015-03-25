require 'rails_helper'

RSpec.describe Community, type: :model do
  context 'validations' do
    subject { FactoryGirl.create(:community) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_uniqueness_of(:slug) }
  end
end
