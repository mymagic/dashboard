class CustomDeviseMailer < Devise::Mailer
  default from: ->(_) { sender_email },
          reply_to: ->(_) { sender_email }

  protected

  def sender_email
    resource.community.email || Devise.mailer_sender
  end
end
