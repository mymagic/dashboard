require 'rails_helper'

RSpec.describe Event, type: :model do
  context 'validations' do
    subject { build(:event) }

    it { is_expected.to validate_presence_of(:creator) }
    it { is_expected.to validate_presence_of(:time_zone) }
    it { is_expected.to validate_presence_of(:location_detail) }
    it { is_expected.to validate_presence_of(:starts_at) }
    it { is_expected.to validate_presence_of(:ends_at) }
    it { is_expected.to validate_presence_of(:title) }
    it do
      is_expected.
        to validate_inclusion_of(:location_type).in_array(Event::LOCATION_TYPES)
    end
  end
end