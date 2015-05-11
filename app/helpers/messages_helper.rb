module MessagesHelper
  def message_body(message)
    highlighted_body = message.try(:highlight).try(:body)
    highlighted_body ? raw(highlighted_body.join('')) : message.body
  end

  def unread_messages_count_for(participant)
    return 0 unless @unread_messages.present?

    @unread_messages.select { |message| message.sender_id == participant.id }
                    .first
                    .try(:unread_count) || 0
  end

  def unread_messages
    current_member.messages.unread
  end
end
