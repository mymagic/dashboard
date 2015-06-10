require 'rails_helper'

RSpec.describe 'Slots', type: :feature, js: false do
  let(:community) { create(:community) }
  let(:mentor) { create(:member, :confirmed, community: community) }
  let(:other_member) { create(:member, :confirmed, community: community) }
  let!(:availability) { create(:availability, member: mentor) }
  let!(:other_availability) { create(:availability, member: other_member) }

  before { as_user mentor }

  describe 'reserve slot' do
    context 'own slot' do
      it 'does not allow me to reserve a slot' do
        visit(
          community_member_availability_slots_path(
            community,
            mentor,
            year: availability.date.year,
            month: availability.date.month,
            day: availability.date.day))

        within 'tbody > tr:first' do
          expect(page).to_not have_content 'Reserve'
        end
      end
    end

    context 'as participant' do
      it 'allows me to reserve a slot' do
        visit(
          community_member_availability_slots_path(
            community,
            other_member,
            year: other_availability.date.year,
            month: other_availability.date.month,
            day: other_availability.date.day))

        within 'tbody > tr:first' do
          click_on 'Reserve'
        end

        expect(page).to have_content 'You have successfully reserved the slot.'
      end
    end
  end
end
