require 'rails_helper'

RSpec.describe Slot, type: :model do
  context 'validations' do
    subject { build(:slot) }

    it { is_expected.to validate_presence_of(:start_time) }
    it { is_expected.to validate_presence_of(:end_time) }
    it { is_expected.to validate_presence_of(:availability) }

    it { is_expected.to belong_to(:member) }
    it { is_expected.to belong_to(:availability) }
  end
end
