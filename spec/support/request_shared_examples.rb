shared_examples "accessible by" do |*authorized_members|
  all_members = {
    administrator: -> (_context) { login_administrator },
    regular_member: -> (_context) { login_member },
    staff: -> (_context) { login_staff },
    mentor: -> (_context) { login_mentor },
    unauthorized: -> (_context) {}
  }

  all_members.map do |role, login|
    if [*authorized_members].include?(role)
      context "#{ role }" do
        before &login
        it "displays the page without errors" do
          expect(response).to_not redirect_to(root_path)
          expect(response).to_not redirect_to(new_member_session_path)
        end
      end
    else
      if role == :unauthorized
        context "#{ role }" do
          before &login
          it "redirects to login page" do
            expect(response).to redirect_to(new_member_session_path)
          end
        end
      else
        context "#{ role }" do
          before &login
          it "redirects to login page" do
            expect(response).to redirect_to(root_path)
          end
        end
      end
    end
  end
end
