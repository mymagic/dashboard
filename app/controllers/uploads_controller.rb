class UploadsController < ApplicationController
  def s3_callback
    uploader = case params[:model]
               when "member" then current_member.avatar
               end

    promise_url = uploader.process_and_upload_to_s3(
      s3_key: params[:key],
      promise_display_style: :large
    )

    render json: { img_url: promise_url }
  end
end
