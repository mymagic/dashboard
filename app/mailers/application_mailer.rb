class ApplicationMailer < ActionMailer::Base
  default from:     :sender_email,
          reply_to: :sender_email

  protected

  def sender_email
    resource.community.email || Devise.mailer_sender
  end
end
