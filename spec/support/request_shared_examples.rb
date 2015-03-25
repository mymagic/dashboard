shared_examples "accessible by" do |*authorized_members|
  all_members = {
    administrator: -> (_context) { login_administrator(community: community) },
    regular_member: -> (_context) { login_member(community: community) },
    staff: -> (_context) { login_staff(community: community) },
    mentor: -> (_context) { login_mentor(community: community) },
    unauthorized: -> (_context) {}
  }

  all_members.map do |role, login|
    if [*authorized_members].include?(role)
      context "#{ role }" do
        before &login
        it "displays the page without errors" do
          expect(response).to_not redirect_to(community_path(community))
          expect(response).to_not redirect_to(new_member_community_session_path(community))
        end
      end
    else
      if role == :unauthorized
        context "#{ role }" do
          before &login
          it "redirects to login" do
            expect(response).to_not redirect_to(new_member_community_session_path(community))
          end
        end
      else
        before &login
        it "redirects to community page" do
          expect(response).to redirect_to(community_path(community))
        end
      end
    end
  end
end
