require 'rails_helper'

RSpec.describe 'Messages', type: :feature, js: false do
  let(:community) { create(:community) }
  let(:administrator) { create(:administrator, :confirmed, community: community) }
  let(:participant) { create(:member, :confirmed, community: community) }
  let!(:send_message) { create(:message, sender: administrator, receiver: participant, body: 'Send Message') }
  let!(:received_message) { create(:message, sender: participant, receiver: administrator, body: 'Received Message') }
  let!(:other_message) { create(:message) }

  before { as_user administrator }

  it 'show all participant messages' do
    visit community_member_messages_path(community, participant)

    expect(page).to have_content send_message.body
    expect(page).to have_content received_message.body
    expect(page).to_not have_content other_message.body
  end

  it 'show unread messages count and disappear after reading them' do
    xpath = "//*[contains(@class, 'messages-panel__participant')]//h4[contains(text(), '#{participant.full_name}')]/span[contains(@class, 'badge')]"

    visit community_member_messages_path(community, participant)

    within(:xpath, xpath) do
      expect(page).to have_content '1'
    end

    visit community_member_messages_path(community, participant)

    expect(page).to_not have_selector('.badge')
  end

  it 'allow send new message' do
    visit community_member_messages_path(community, participant)

    fill_in 'message_body', with: 'New Message'
    click_button 'Send'

    expect(page).to have_content 'Message has already send.'
    expect(page).to have_content 'New Message'
  end

  it 'allows to search related messages', elasticsearch: Message do
    elasticsearch.wait!
    visit community_member_messages_path(community, participant)

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
