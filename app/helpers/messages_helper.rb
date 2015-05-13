module MessagesHelper
  def message_body(message)
    highlighted_body = message.try(:highlight).try(:body)
    if highlighted_body
      participant_id = message.sender_id == current_member.id ? message.receiver_id : message.sender_id

      link_to community_member_messages_path(current_community, participant_id) do
        raw(highlighted_body.join(''))
      end
    else
      message.body
    end
  end

  def unread_messages_count_for(participant)
    return 0 unless @unread_messages.present?

    @unread_messages.select { |message| message.sender_id == participant.id }
                    .first
                    .try(:unread_count) || 0
  end

  def unread_messages
    current_member.messages.unread.where.not(sender: current_member)
  end

  def small_avatar_for(message)
    image_tag message.sender.avatar.small_thumb.url
  end
end
