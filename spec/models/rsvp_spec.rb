require 'rails_helper'

RSpec.describe Rsvp, type: :model do
  context 'validations' do
    subject { build(:rsvp) }
    it { is_expected.to validate_presence_of(:member) }
    it { is_expected.to validate_presence_of(:event) }
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_inclusion_of(:state).in_array(Rsvp::STATES) }

    context 'with an event in the past' do
      let(:event) { create(:event, :in_the_past) }
      subject do
        build(:rsvp,
              event: event,
              member: create(:member, community: event.community))
      end
      it 'adds an error that the event cannot be in the past' do
        is_expected.to be_invalid
        expect(subject.errors.full_messages).
          to include("Event cannot be a past event")
      end
    end
  end
end
