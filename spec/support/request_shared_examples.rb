shared_examples "accessible by" do |*authorized_members|
  all_members = {
    administrator: -> (_context) { login_administrator(community: community) },
    regular_member: -> (_context) { login_member(community: community) },
    staff: -> (_context) { login_staff(community: community) },
    mentor: -> (_context) { login_mentor(community: community) },
    unauthenticated: -> (_context) { unauthenticated }
  }

  all_members.map do |role, login|
    if [*authorized_members].include?(role)
      context "#{ role }" do
        before &login
        it "displays the page without errors" do
          expect(response).to_not redirect_to(root_path)
          expect(response).to_not redirect_to(community_path(community))
          expect(response).to_not redirect_to(new_member_session_path(community))
        end
      end
    else
      if role == :unauthenticated
        context "#{ role }" do
          before &login
          it "redirects to login" do
            expect(response).to redirect_to(new_member_session_path(community))
          end
        end
      else
        before &login
        context "#{ role }" do
          it "redirects to community page" do
            expect(response).to redirect_to(community_path(community))
          end
        end
      end
    end
  end
end

shared_examples "logging in" do
  it "logs the user in" do
    visit community_path(community)
    expect_to_require_signing_in
    log_in community, user.email
    expect_to_be_signed_in
  end
end

shared_examples "logging out" do
  it "logs the user out" do
    log_in community, user.email
    expect_to_be_signed_in
    sign_out
  end
end

shared_examples "canceling account" do
  it "cancels the members account" do
    cancel_my_account(community)
    expect(page).to have_content('Your account has been successfully cancelled')
  end
end

shared_examples "changing first name" do
  background { as_user user }
  it "changes my first name" do
    visit root_path
    within(:css, 'nav.navbar-member') do
      expect(page).to have_content(user.first_name)
    end
    update_my_account(community: community, first_name: 'NewFirstName')
    within(:css, 'nav.navbar-member') do
      expect(page).to have_content('NewFirstName')
    end
  end
end
