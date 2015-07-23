require 'rails_helper'

RSpec.describe Rsvp, type: :model do
  let(:network) { create(:community).networks.first }
  context 'validations' do
    subject { build(:rsvp) }
    it { is_expected.to validate_presence_of(:member) }
    it { is_expected.to validate_presence_of(:event) }
    it { is_expected.to validate_presence_of(:state) }
    it { is_expected.to validate_inclusion_of(:state).in_array(Rsvp::STATES) }

    context 'with an event in the past' do
      let(:event) { create(:event, :in_the_past, network: network) }
      subject do
        build(:rsvp,
              event: event,
              member: create(:member, community: event.network.community))
      end
      it 'adds an error that the event cannot be in the past' do
        is_expected.to be_invalid
        expect(subject.errors.full_messages).
          to include("Event cannot be a past event")
      end
    end

    context 'activitiy' do
      context 'after creating a rsvp' do
        let!(:rsvp) { create(:rsvp) }
        it 'created a new rsvp activity' do
          expect(
            Activity::Rsvping.find_by(
              owner: rsvp.member,
              event: rsvp.event)
          ).to_not be_nil
        end
        it 'stores the state as data' do
          activity = Activity::Rsvping.find_by(
            owner: rsvp.member, event: rsvp.event)
          expect(activity.state).to eq rsvp.state
        end
      end
    end
  end
end
