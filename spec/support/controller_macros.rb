module ControllerMacros
  def login_administrator(*args)
    @request.env["devise.mapping"] = Devise.mappings[:member]
    user = create(:administrator, :confirmed, *args)
    set_magic_connect_cookies user.email
    sign_in user
  end

  def login_member(*args)
    @request.env["devise.mapping"] = Devise.mappings[:member]
    user = create(:member, :confirmed, *args)
    set_magic_connect_cookies user.email
    sign_in user
  end

  def login_mentor(*args)
    @request.env["devise.mapping"] = Devise.mappings[:member]
    user = create(:mentor, :confirmed, *args)
    set_magic_connect_cookies user.email
    sign_in user
  end

  def login_staff(*args)
    @request.env["devise.mapping"] = Devise.mappings[:member]
    user = create(:staff, :confirmed, *args)
    set_magic_connect_cookies user.email
    sign_in user
  end

  def login(member)
    @request.env["devise.mapping"] = Devise.mappings[:member]
    set_magic_connect_cookies member.email
    sign_in member
  end

  def set_magic_connect_cookies(email)
    @request.cookies['magic_cookie'] = Base64.encode64("123|||#{ email }|||secret")
  end

  def unauthenticated
    @request.env["warden"].logout
  end
end
