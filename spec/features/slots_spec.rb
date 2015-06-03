require 'rails_helper'

RSpec.describe 'Slots', type: :feature, js: false do
  let(:community) { create(:community) }
  let(:administrator) { create(:administrator, :confirmed, community: community) }
  let(:other_member) { create(:member, :confirmed, community: community) }
  let!(:own_availability) { create(:availability, member: administrator) }
  let!(:another_availability) { create(:availability, member: other_member) }

  before { as_user administrator }

  describe 'reserve slot' do
    context 'own slot' do
      it 'does not allow to reserve a slot' do
        visit community_member_availability_path(community, administrator, own_availability)

        within 'tbody > tr:first' do
          expect(page).to_not have_content 'Reserve'
        end
      end
    end

    context 'as participant' do
      it 'allow to reserve a slot' do
        visit community_member_availability_path(community, other_member, another_availability)

        within 'tbody > tr:first' do
          click_on 'Reserve'
        end

        expect(page).to have_content 'You have successfully reserved the slot.'
      end
    end
  end
end
