require 'rails_helper'

RSpec.describe 'Messages', type: :feature, js: false do
  let(:community) { create(:community) }
  let(:administrator) { create(:administrator, :confirmed, community: community) }
  let(:participant) { create(:member, :confirmed, community: community) }
  let!(:send_message) { create(:message, sender: administrator, receiver: participant) }
  let!(:received_message) { create(:message, sender: participant, receiver: administrator) }
  let!(:other_message) { create(:message) }

  before { as_user administrator }

  it 'show all participant messages' do
    visit community_member_messages_path(community, participant)

    expect(page).to have_content send_message.body
    expect(page).to have_content received_message.body
    expect(page).to_not have_content other_message.body
  end

  it 'allow send new message' do
    visit community_member_messages_path(community, participant)

    fill_in 'message_body', with: 'New Message'
    click_button 'Send'

    expect(page).to have_content 'Message has already send.'
    expect(page).to have_content 'New Message'
  end
end
