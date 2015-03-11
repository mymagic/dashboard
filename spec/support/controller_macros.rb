module ControllerMacros
  def login_administrator
    @request.env["devise.mapping"] = Devise.mappings[:member]
    sign_in create(:administrator, :confirmed)
  end

  def login_member
    @request.env["devise.mapping"] = Devise.mappings[:member]
    sign_in create(:member, :confirmed)
  end

  def login_mentor
    @request.env["devise.mapping"] = Devise.mappings[:member]
    sign_in create(:mentor, :confirmed)
  end

  def login_staff
    @request.env["devise.mapping"] = Devise.mappings[:member]
    sign_in create(:staff, :confirmed)
  end

  def current_community
    controller.current_member.try(:community)
  end
end
