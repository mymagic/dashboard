class NotificationMailer < ApplicationMailer
  layout 'notification'

  def follower_notification(receiver, follower:)
    @receiver = receiver
    @follower = follower
    mail(
      to: receiver.email,
      subject: "#{ follower.full_name } has started following you"
    )
  end

  def comment_notification(receiver, author:, discussion:)
    @receiver   = receiver
    @author     = author
    @discussion = discussion
    mail(
      to: receiver.email,
      subject: "#{ @author.full_name } commented on #{ @discussion.title }"
    )
  end

  def message_notification(receiver, message:)
    @receiver = receiver
    @sender   = message.sender
    @body     = message.body
    mail(
      to: receiver.email,
      subject: "#{ @sender.full_name } has sent you a new message"
    )
  end
end
