module ControllerMacros
  def login_administrator(*args)
    @request.env["devise.mapping"] = Devise.mappings[:member]
    sign_in create(:administrator, :confirmed, *args)
  end

  def login_member(*args)
    @request.env["devise.mapping"] = Devise.mappings[:member]
    sign_in create(:member, :confirmed, *args)
  end

  def login_mentor(*args)
    @request.env["devise.mapping"] = Devise.mappings[:member]
    sign_in create(:mentor, :confirmed, *args)
  end

  def login_staff(*args)
    @request.env["devise.mapping"] = Devise.mappings[:member]
    sign_in create(:staff, :confirmed, *args)
  end

  def login(member)
    @request.env["devise.mapping"] = Devise.mappings[:member]
    sign_in member
  end

  def unauthenticated
    @request.env["warden"].logout
  end
end
