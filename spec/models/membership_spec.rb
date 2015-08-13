require 'rails_helper'

RSpec.describe Membership, type: :model do
  context 'validations' do
    subject { FactoryGirl.create(:membership) }

    it { is_expected.to validate_presence_of(:member) }
    it { is_expected.to validate_presence_of(:network) }
    it do
      is_expected.to validate_uniqueness_of(:member_id).scoped_to(:network_id)
    end
  end
end
