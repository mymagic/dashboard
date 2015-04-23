module FeatureHelper
  # Helper for Warden login without having to go through UI. For faster sign-in
  def as_user(member, &block)
    login_as(member, scope: :member, community_id: member.community)
    block.call if block.present?
    self
  end

  def sign_out
    find('#navbar > ul.nav.navbar-nav.navbar-right').click
    click_on 'Sign out'

    # Verify that user was successfully logged out back to the landing page
    expect(page).to have_content 'Signed out successfully.'
  end

  def expect_to_be_signed_out
    within(:css, 'nav.navbar-member') do
      expect(page).to have_content("Log in")
    end
  end

  def expect_to_be_signed_in
    within(:css, 'nav.navbar-member') do
      expect(page).to have_content("Sign out")
    end
  end

  def log_in(community, email, password = 'password0')
    visit new_member_session_path(community)

    fill_in 'Email',  with: email
    fill_in 'Password', with: password

    click_button 'Log in'
  end

  def expect_successful_password_reset(member)
    reset_password(member)
    expect(page).to have_content 'Your password has been changed '\
                            'successfully. You are now signed in.'
  end

  def reset_password(member, new_password = 'newpassword0')
    visit new_member_session_path(member.community)
    click_link "Forgot your password?"

    expect(page).to have_content 'Forgot your password?'

    fill_in 'Email', with: member.email

    click_button 'Send me reset password instructions'

    open_email(member.email)

    current_email.click_link 'Change my password'

    expect(page).to have_content 'Change your password'

    fill_in 'New password', with: new_password
    fill_in 'Confirm your new password', with: new_password

    click_button 'Change my password'
  end

  def invite_new_member(email:, community:, attributes: {})
    attributes = {
      first_name: 'Firstname', last_name: 'Lastname', role: 'Regular Member'
    }.merge!(attributes)

    visit new_community_admin_member_path(community)

    fill_in 'Email',  with: email
    fill_in 'First name',  with: attributes[:first_name]
    fill_in 'Last name',  with: attributes[:last_name]
    select attributes[:role], from: 'Role'

    select attributes[:company], from: 'Company' if attributes[:company]
    select attributes[:position], from: 'Position'  if attributes[:position]

    click_button 'Invite'

    expect(page).to have_content("Member was successfully invited.")
  end

  def invite_new_company_member(company, email, attributes = {})
    visit new_community_company_member_path(company.community, company)

    fill_in 'Email',  with: email
    fill_in 'First name',  with: attributes[:first_name] if attributes[:first_name]
    fill_in 'Last name',  with: attributes[:last_name] if attributes[:last_name]

    select attributes[:position], from: 'Position'  if attributes[:position]

    click_button 'Invite'

    expect(page).to have_content("Member was successfully invited.")
  end

  def update_my_account(attributes = {})
    visit edit_member_registration_path(attributes[:community])

    fill_in 'First name',  with: attributes[:first_name] if attributes[:first_name]
    fill_in 'Last name',  with: attributes[:last_name] if attributes[:last_name]
    fill_in 'Password',  with: attributes[:password] if attributes[:password]

    fill_in 'Current password',  with: attributes[:current_password] if attributes[:current_password]

    if attributes[:social_media_link]
      select attributes[:social_media_link][:service], from: 'Service'
      fill_in 'Handle', with: attributes[:social_media_link][:handle]
    end

    if attributes[:password_confirmation] || attributes[:password]
      fill_in 'Password confirmation',  with: attributes[:password_confirmation] || attributes[:password]
    end

    click_button 'Update'

    expect(page).to have_content("Your account has been updated successfully.")
  end

  def cancel_my_account(community)
    visit edit_member_registration_path(community)

    click_link 'Cancel my account'

    expect(page).to have_content(
      "Bye! Your account has been successfully cancelled. "\
      "We hope to see you again soon.")
  end

  def have_unauthorized_message
    have_selector('.alert', text: 'You are not authorized to access this page.')
  end

  def manage_company_members_positions(approved: [], approve: [], reject: [], remove: [], update: [])
    pending = approve + reject
    already_approved =  approved + remove
    another_position = create(:position, community: approved.first.position.community) if update.any?

    already_approved.each do |cmp|
      within '#approved' do
        expect(page).to have_content("#{ cmp.position.name }")
      end
      within '#pending' do
        expect(page).to_not have_content("#{ cmp.position.name }")
      end
    end

    update.each do |cmp|
      old_position_name = cmp.position.name

      within(:xpath, "//*[@id='approved']/table/tbody/tr/td[text()='#{ old_position_name }']/..") do
        click_link 'Edit'
      end

      select another_position.name, from: 'Position'
      click_button 'Save'

      expect(page).to have_content('Companies Members Position was successfully updated.')

      within '#approved' do
        expect(page).to have_content("#{ another_position.name }")
        expect(page).to_not have_content("#{ old_position_name }")
      end
    end

    expect(page).to have_content("Pending #{ pending.count}") if pending.any?

    pending.each do |cmp|
      within '#approved' do
        expect(page).to_not have_content("#{ cmp.position.name }")
      end
      within '#pending' do
        expect(page).to have_content("#{ cmp.position.name }")
      end
    end

    approve.each do |cmp|
      within(:xpath, "//*[@id='pending']/table/tbody/tr/td[text()='#{ cmp.position.name }']/..") do
        click_link "Approve"
      end
      expect(page).to have_content("Position was successfully approved.")
      within '#approved' do
        expect(page).to have_content("#{ cmp.position.name }")
      end
    end

    reject.each do |cmp|
      within(:xpath, "//*[@id='pending']/table/tbody/tr/td[text()='#{ cmp.position.name }']/..") do
        click_link "Reject"
      end
      expect(page).to have_content("Position was successfully rejected.")
      expect(page).to_not have_content("#{ cmp.position.name }")
    end

    remove.each do |cmp|
      within(:xpath, "//*[@id='approved']/table/tbody/tr/td[text()='#{ cmp.position.name }']/..") do
        click_link "Remove"
      end
      expect(page).to have_content("Members position has been removed.")
      within '#approved' do
        expect(page).to_not have_content("#{ cmp.position.name }")
      end
    end
  end

  # Taken from "Spreewald" gem https://github.com/makandra/spreewald/blob/master/lib/spreewald_support/tolerance_for_selenium_sync_issues.rb
  # <<<
  RETRY_ERRORS = %w[
    Capybara::ElementNotFound
    Spec::Expectations::ExpectationNotMetError
    RSpec::Expectations::ExpectationNotMetError
    Minitest::Assertion
    Capybara::Poltergeist::ClickFailed
    Capybara::ExpectationNotMet
    Selenium::WebDriver::Error::StaleElementReferenceError
    Selenium::WebDriver::Error::NoAlertPresentError
    Selenium::WebDriver::Error::ElementNotVisibleError
    Selenium::WebDriver::Error::NoSuchFrameError
    Selenium::WebDriver::Error::NoAlertPresentError
  ]

  # This is similiar but not entirely the same as Capybara::Node::Base#wait_until or Capybara::Session#wait_until
  def patiently(seconds=Capybara.default_wait_time, &block)
    old_wait_time = Capybara.default_wait_time
    # dont make nested wait_untils use up all the alloted time
    Capybara.default_wait_time = 0 # for we are a jealous gem
    if page.driver.wait?
      start_time = Time.now
      begin
        block.call
      rescue Exception => e
        raise e unless RETRY_ERRORS.include?(e.class.name)
        raise e if (Time.now - start_time) >= seconds
        sleep(0.05)
        raise Capybara::FrozenInTime, "time appears to be frozen, Capybara does not work with libraries which freeze time, consider using time travelling instead" if Time.now == start_time
        retry
      end
    else
      block.call
    end
  ensure
    Capybara.default_wait_time = old_wait_time
  end
  # >>>
end
