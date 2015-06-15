require 'rails_helper'

RSpec.describe 'Slots', type: :feature, js: false do
  let(:community) { create(:community) }
  let(:other_member) { create(:member, :confirmed, community: community) }
  let!(:other_availability) { create(:availability, member: other_member) }

  let(:administrator) do
    create(:administrator, :confirmed, community: community)
  end
  let(:staff) { create(:staff, :confirmed, community: community) }
  let(:mentor) { create(:mentor, :confirmed, community: community) }
  let(:regular_member) { create(:member, :confirmed, community: community) }


  shared_examples_for 'reserving a slot' do

    before { as_user member }

    context 'own slot' do
      let!(:availability) { create(:availability, member: member) }
      it 'does not allow me to reserve a slot' do
        visit(
          community_member_availability_slots_path(
            community,
            member,
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

        visit community_path(community)
        within '.activity-group' do
          expect(page).
            to have_content "#{ member.full_name } booked office hours with "\
                            "#{ other_member.full_name }"
        end
      end
    end
  end

  context 'as administrator' do
    let(:member) { administrator }
    it_behaves_like "reserving a slot"
  end

  context 'as staff' do
    let(:member) { administrator }
    it_behaves_like "reserving a slot"
  end

  context 'as mentor' do
    let(:member) { mentor }
    it_behaves_like "reserving a slot"
  end

  context 'as member' do
    let(:member) { regular_member }
    it_behaves_like "reserving a slot"
  end
end
