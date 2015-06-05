require 'rails_helper'

RSpec.describe 'Messages', type: :feature, js: false do
  shared_examples "sending a new message" do
    it 'allows to send a new message' do
      visit community_member_messages_path(community, bob)

      fill_in 'message_body', with: 'Lorem ipsum'
      click_button 'Send'

      expect(page).to have_content 'Message has been sent.'

      within '.messages-panel__conversations' do
        expect(page).to have_content 'Lorem ipsum'
      end
    end
  end

  let(:community) { create(:community) }
  let(:alice) { create(:member, :confirmed, community: community) }
  let(:bob) { create(:member, :confirmed, community: community) }

  before { as_user alice }
  context 'with messages' do
    let!(:send_message) do
      create(
        :message,
        sender: alice,
        receiver: bob,
        body: 'Send Message')
    end
    let!(:received_message) do
      create(
        :message,
        sender: bob,
        receiver: alice,
        body: 'Received Message')
    end
    let!(:last_message) do
      create(
        :message,
        sender: alice,
        receiver: bob,
        body: 'Last Message')
    end
    let!(:other_message) { create(:message) }

    it_behaves_like 'sending a new message'

    it 'show all participant messages' do
      visit community_member_messages_path(community, bob)

      within '.messages-panel__conversations .message-box:nth-child(1)' do
        expect(page).to have_content send_message.body
      end
      within '.messages-panel__conversations .message-box:nth-child(2)' do
        expect(page).to have_content received_message.body
      end
      within '.messages-panel__conversations .message-box:nth-child(3)' do
        expect(page).to have_content last_message.body
      end
      expect(page).to_not have_content other_message.body
    end

    it 'show unread messages count and disappear after reading them' do
      xpath = "//*[contains(@class, 'messages-panel__participant')]"\
              "//h4[contains(text(), '#{ bob.full_name }')]/"\
              "span[contains(@class, 'badge')]"

      visit community_member_messages_path(community, bob)

      within(:xpath, xpath) do
        expect(page).to have_content '1'
      end

      visit community_member_messages_path(community, bob)

      expect(page).to_not have_selector('.badge')
    end

    it 'allows to search related messages', elasticsearch: Message do
      elasticsearch.wait!
      visit community_member_messages_path(community, bob)

      fill_in 'Search', with: 'Message'
      click_button 'search-message-btn'

      expect(page).to have_content 'Send Message'
      expect(page).to have_content 'Received Message'

      fill_in 'Search', with: 'Send'
      click_button 'search-message-btn'

      expect(page).to have_content 'Send Message'
      expect(page).to_not have_content 'Received Message'
    end
  end

  context 'without any messages' do
    it_behaves_like 'sending a new message'

    it 'shows a note that there are no conversations yet' do
      visit community_messages_path(community)

      expect(page).
        to have_content "You've not participated in any conversations yet"
    end
  end
end
