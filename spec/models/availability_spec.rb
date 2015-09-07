require 'rails_helper'

RSpec.describe Availability, type: :model do
  context 'validations' do
    subject { build(:availability) }

    it { is_expected.to validate_presence_of(:date) }
    it { is_expected.to validate_presence_of(:time) }
    it { is_expected.to validate_presence_of(:slot_duration) }
    it { is_expected.to validate_presence_of(:time_zone) }
    it { is_expected.to validate_presence_of(:location_type) }
    it { is_expected.to validate_presence_of(:location_detail) }

    it { is_expected.to belong_to(:member) }
    it { is_expected.to have_and_belong_to_many(:networks) }
    it { is_expected.to have_many(:slots) }
  end
end
