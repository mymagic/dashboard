class UploadsController < ApplicationController
  def s3_callback
    uploader = case params[:model]
               when "member" then member_avatar
               when "company" then company_logo
               end

    promise_url = uploader.process_and_upload_to_s3(
      s3_key: params[:key],
      promise_display_style: :thumb
    )

    render json: { img_url: promise_url }
  end

  private

  def member_avatar
    return current_member.avatar unless params[:id].present?
    member = Member.find(params[:id])
    member.avatar if can? :edit, member
  end

  def company_logo
    company = Company.find(params[:id])
    return company.logo if can? :edit, company
  end
end
