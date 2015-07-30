class MagicConnectAccountCreationJob < ActiveJob::Base
  queue_as :default

  def perform(model)
    model.create_magic_connect_account!
  end
end
