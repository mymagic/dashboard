class NotificationMailer < ApplicationMailer
  layout 'notification'
  helper ApplicationHelper

  NOTIFICATIONS = %w(
    follower_notification
    comment_notification
    message_notification
    mentor_slot_reserve_notification
    mentor_slot_cancel_notification
    participant_slot_reserve_notification
    participant_slot_cancel_notification
    event_rsvp_notification
    discussion_notification
  )

  def follower_notification(receiver, follower:, network:)
    @receiver = receiver
    @follower = follower
    @network  = network
    mail(
      to: receiver.email,
      subject: "#{ follower.full_name } has started following you"
    )
  end

  def comment_notification(receiver, comment:)
    @receiver   = receiver
    @author     = comment.author
    @discussion = comment.discussion
    @comment    = comment
    mail(
      to: receiver.email,
      subject: "#{ @author.full_name } commented on #{ @discussion.title }"
    )
  end

  def message_notification(receiver, message:, network:)
    @receiver = receiver
    @sender   = message.sender
    @body     = message.body
    @network  = network
    mail(
      to: receiver.email,
      subject: "#{ @sender.full_name } has sent you a new message"
    )
  end

  def mentor_slot_reserve_notification(receiver, slot:, participant:, network:)
    @receiver = receiver
    @availability = slot.availability
    @participant = participant
    @date_and_time = slot_datetime_string(slot)
    @network = network

    mail(
      to: receiver.email,
      subject: "#{ @participant.full_name } has reserved "\
               "an office hour on #{ @date_and_time }"
    )
  end

  def participant_slot_reserve_notification(receiver, slot:, mentor:, network:)
    @receiver = receiver
    @availability = slot.availability
    @mentor = mentor
    @date_and_time = slot_datetime_string(slot)
    @network = network

    mail(
      to: receiver.email,
      subject: "You have reserved an office hour with #{ mentor.full_name } "\
               "on #{ @date_and_time }"
    )
  end

  def participant_slot_cancel_notification(receiver, slot:, mentor:, network: nil)
    @receiver = receiver
    @availability = slot.availability
    @mentor = mentor
    @date_and_time = slot_datetime_string(slot)

    mail(
      to: receiver.email,
      subject: "The office hour with #{ mentor.full_name } "\
               "on #{ @date_and_time } has been cancelled"
    )
  end

  def mentor_slot_cancel_notification(receiver, slot:, participant:, network: nil)
    @receiver = receiver
    @availability = slot.availability
    @participant = participant
    @date_and_time = slot_datetime_string(slot)

    mail(
      to: receiver.email,
      subject: "The office hour with #{ @participant.full_name } "\
               "on #{ @date_and_time } has been cancelled"
    )
  end

  def event_rsvp_notification(receiver, event:, rsvp:, network:)
    @receiver = receiver
    @event = event
    @rsvp = rsvp
    @network = network
    mail(
      to: receiver.email,
      subject: "You have RSVP'd to #{ @event.title } as #{ @rsvp }"
    )

  end

  def discussion_notification(receiver, author:, discussion:)
    @receiver = receiver
    @author = author
    @discussion = discussion
    mail(
      to: receiver.email,
      subject: "#{author.full_name} has created a new "\
               "discussion: #{discussion.title}"
    )

  end

  private

  def slot_datetime_string(slot)
    "#{ slot.date.strftime('%B %d, %Y') } between "\
    "#{ slot.start_time.in_time_zone(slot.time_zone).strftime('%H:%M') }-"\
    "#{ slot.end_time.in_time_zone(slot.time_zone).strftime('%H:%M') } "\
    "(#{ slot.time_zone })"
  end

end
