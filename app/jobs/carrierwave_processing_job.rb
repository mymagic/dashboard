class CarrierwaveProcessingJob < ActiveJob::Base
  queue_as :default

  def perform(model, uploader_name)
    model.send(uploader_name).recreate_versions!
  end
end
