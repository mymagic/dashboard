require 'rails_helper'

RSpec.describe OfficeHour, type: :model do
  context 'validations' do
    subject { build(:office_hour) }

    it { is_expected.to validate_presence_of(:mentor) }
    it { is_expected.to validate_presence_of(:time) }
    it { is_expected.to validate_presence_of(:time_zone) }
  end

  let(:office_hour) { build(:office_hour) }
  let(:booked_office_hour) { build(:office_hour, :booked) }

  describe '#available?' do
    context 'as a new office hour' do
      subject { office_hour.available? }
      it { is_expected.to be_truthy }
    end
    context 'as a booked office hour' do
      subject { booked_office_hour.available? }
      it { is_expected.to be_falsy }
    end
  end

  describe '#booked?' do
    context 'as a new office hour' do
      subject { office_hour.booked? }
      it { is_expected.to be_falsy }
    end
    context 'as a booked office hour' do
      subject { booked_office_hour.booked? }
      it { is_expected.to be_truthy }
    end
  end

  describe '#time_in_zone' do
    let(:time) { "1985-06-30 10:00:00" }
    let(:time_in_utc) { ActiveSupport::TimeZone["UTC"].parse(time) }
    let(:time_zone) { 'Bangkok' }
    let(:time_in_zone) { ActiveSupport::TimeZone[time_zone].parse(time) }
    before do
      office_hour.time_zone = time_zone
      office_hour.time      = time_in_utc
    end
    subject { office_hour.time_in_zone }
    it { is_expected.to eq time_in_zone }
  end
end
