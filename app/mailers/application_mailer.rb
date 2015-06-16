class ApplicationMailer < ActionMailer::Base
  default from: ->(_) { sender_email },
          reply_to: ->(_) { sender_email }

  protected

  def sender_email
    if @receiver.present?
      @receiver.community.email || Devise.mailer_sender
    else
      resource.community.email || Devise.mailer_sender
    end
  end
end
