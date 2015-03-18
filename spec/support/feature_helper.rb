module FeatureHelper
  # Helper for Warden login without having to go through UI. For faster sign-in
  def as_user(member, &block)
    login_as(member, scope: :member)
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

  def log_in(email, password = 'password0')
    visit new_member_session_path

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
    visit new_member_session_path
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

  def invite_new_member(email, attributes={})
    attributes = {
      first_name: 'Firstname', last_name: 'Lastname', role: 'Regular Member'
    }.merge!(attributes)

    visit new_admin_member_path

    fill_in 'Email',  with: email
    fill_in 'First name',  with: attributes[:first_name]
    fill_in 'Last name',  with: attributes[:last_name]
    select attributes[:role], from: 'Role'

    select attributes[:company], from: 'Company' if attributes[:company]
    select attributes[:position], from: 'Position'  if attributes[:position]

    click_button 'Invite'

    expect(page).to have_content("Member was successfully invited.")
  end

  def update_my_account(attributes = {})
    visit edit_member_registration_path

    fill_in 'First name',  with: attributes[:first_name] if attributes[:first_name]
    fill_in 'Last name',  with: attributes[:last_name] if attributes[:last_name]
    fill_in 'Password',  with: attributes[:password] if attributes[:password]

    if attributes[:password_confirmation]
      fill_in 'Password confirmation',  with: attributes[:password_confirmation]
    end

    click_button 'Update'

    expect(page).to have_content("Your account has been updated successfully.")
  end

  def cancel_my_account
    visit edit_member_registration_path

    click_link 'Cancel my account'

    expect(page).to have_content(
      "Bye! Your account has been successfully cancelled. "\
      "We hope to see you again soon.")
  end

  def have_unauthorized_message
    have_selector('.alert', text: 'You are not authorized to access this page.')
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
