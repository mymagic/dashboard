shared_examples "only accessible by administrator" do
  context "unauthenticated" do
    it "redirects to login page" do
      expect(response).to redirect_to(new_member_session_path)
    end
  end

  context "for regular member" do
    before { login_member }
    it "redirects to root page" do
      expect(response).to redirect_to(root_path)
    end
  end

  context "for mentor" do
    before { login_mentor }
    it "redirects to root page" do
      expect(response).to redirect_to(root_path)
    end
  end

  context "for staff" do
    before { login_staff }
    it "redirects to root page" do
      expect(response).to redirect_to(root_path)
    end
  end

  context "for authorized user" do
    before { login_administrator }
    it "displays page without errors" do
      expect(response).to_not redirect_to(root_path)
      expect(response).to_not redirect_to(new_member_session_path)
    end
  end
end
