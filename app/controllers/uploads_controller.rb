class UploadsController < ApplicationController
  def s3_callback
    uploader = case params[:model]
               when "member" then member_avatar
               when "company" then company_logo
               when "community" then community_logo
               end

    promise_url = uploader.process_and_upload_to_s3(
      s3_key: params[:key],
      promise_display_style: :thumb
    )

    render json: { img_url: promise_url }
  end

  private

  def member_avatar
    if params[:invitation_token].present?
      Member.find_by_invitation_token(params[:invitation_token], true).avatar
    elsif params[:id].present?
      member = Member.find(params[:id])
      member.avatar if can? :edit, member
    else
      current_member.avatar
    end
  end

  def company_logo
    company = Company.find(params[:id])
    return company.logo if can? :edit, company
  end

  def community_logo
    community = Community.find(params[:id])
    return community.logo if can? :edit, community
  end
end
