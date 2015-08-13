require 'rails_helper'

RSpec.describe Network, type: :model do
  context 'validations' do
    subject { FactoryGirl.create(:network) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
    it { is_expected.to validate_uniqueness_of(:slug) }
  end
end
