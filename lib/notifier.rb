module Notifier
  def self.deliver(type, receiver, **kwargs)
    return unless receiver.receive?(type)
    NotificationMailer.send(type, receiver, **kwargs).deliver_later
  end
end
