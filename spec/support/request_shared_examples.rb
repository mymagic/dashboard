shared_examples "accessible by" do |*authorized_members|
  all_members = {
    administrator: -> (_context) { login_administrator },
    regular_member: -> (_context) { login_member },
    staff: -> (_context) { login_staff },
    mentor: -> (_context) { login_mentor },
    # unauthorized: -> (_context) {}
  }

  all_members.map do |role, login|
    if [*authorized_members].include?(role)
      context "#{ role }" do
        before &login
        it "displays the page without errors" do
          expect(response).to_not redirect_to(root_path)
          expect(response).to_not redirect_to(new_member_community_session_path(current_community))
        end
      end
    else
      if role == :unauthorized
        context "#{ role }" do
          before &login
          it "redirects to login" do
            expect(response).to redirect_to(root_path)
          end
        end
      else
        context "#{ role }" do
          controller(SessionsController) do
            def after_sign_up_path_for(resource)
              super resource
            end
          end

          before &login
          it "redirects to company page" do
            expect(controller.after_sign_in_path_for(controller.current_member)).to eq community_path(current_community)
          end
        end
      end
    end
  end
end
