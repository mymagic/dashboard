module MessagesHelper
  def message_body(message)
    highlighted_body = message.try(:highlight).try(:body)
    highlighted_body ? raw(highlighted_body.join('')) : message.body
  end
end
