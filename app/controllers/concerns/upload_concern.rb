module UploadConcern
  extend ActiveSupport::Concern

  included do
    before_action :set_upload_settings, only: [:edit, :update]
  end

  private

  def set_upload_settings
    resource = resource_to_upload
    s3_direct_upload_data = resource.s3_direct_upload_data
    gon.directUploadUrl = s3_direct_upload_data.url
    gon.directUploadFormData = s3_direct_upload_data.fields
    gon.model = resource.model.class.name.downcase
  end
end
