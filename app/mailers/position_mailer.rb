class PositionMailer < CustomDeviseMailer
  def send_position_change(member, recipient, company, position)
    @member = member
    @recipient = recipient
    @company = company
    @position = position

    mail to: @recipient.email,
         subject: 'Requesting position change need to be approved.'
  end

  def send_approve_notification(member, position)
    @member = member
    @position = position

    mail to: @member.email,
         subject: 'Your position change request has been approved.'
  end

  def send_reject_notification(member, position)
    @member = member
    @position = position

    mail to: @member.email,
         subject: 'Your position change request has been rejected.'
  end
end
