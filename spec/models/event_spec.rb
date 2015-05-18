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

  let(:event) { build(:event) }

  describe '#time_in_zone' do
    let(:time) { "1985-06-30 10:00:00" }
    let(:time_in_utc) { ActiveSupport::TimeZone["UTC"].parse(time) }
    let(:time_zone) { 'Bangkok' }
    let(:time_in_zone) { ActiveSupport::TimeZone[time_zone].parse(time) }
    before do
      event.time_zone = time_zone
    end
    subject { event.send(:time_in_zone, time) }
    it { is_expected.to eq time_in_zone }
  end
end
