module FeatureHelper
  # Helper for Warden login without having to go through UI. For faster sign-in
  def as_user(member, &block)
    login_as(member, scope: :member, community_id: member.community)
    block.call if block.present?
    self
  end

  def sign_out
    click_on 'Sign out', match: :first
    expect(page).to_not have_content 'Sign out'
  end

  def expect_to_be_signed_out
    expect(page).to have_content 'Signed out successfully.'
  end

  def expect_to_require_signing_in
    expect(page).to have_content 'You need to sign in before continuing.'
  end

  def magic_connect_cookie(email)
    create_cookie(
      'magic_cookie',
      Base64.encode64("123|||#{ email }|||secret"))
  end

  def expect_to_be_signed_in
    within(:css, 'nav.navbar-standard') do
      expect(page).to have_content("Sign out")
    end
  end

  def log_in(community, email, password = 'password0')
    magic_connect_cookie(email)
    visit community_path(community)
  end

  def invite_new_member(email:, community:, attributes: {})
    attributes = {
      first_name: 'Firstname', last_name: 'Lastname', role: 'Regular Member'
    }.merge!(attributes)

    visit new_community_admin_member_path(community)

    fill_in 'Email',  with: email
    fill_in 'First name',  with: attributes[:first_name]
    fill_in 'Last name',  with: attributes[:last_name]

    check community.networks.first.name

    select attributes[:role], from: 'Role'

    select attributes[:company], from: 'Company' if attributes[:company]
    click_button 'Invite'

    expect(page).to have_content("Member was successfully invited.")
  end

  def invite_new_company_member(company:, network:, email:, attributes: {})
    visit new_community_network_company_member_path(network.community,
                                                    network,
                                                    company)

    fill_in 'Email',  with: email
    fill_in 'First name',  with: attributes[:first_name] if attributes[:first_name]
    fill_in 'Last name',  with: attributes[:last_name] if attributes[:last_name]

    select attributes[:position], from: 'Position'  if attributes[:position]

    click_button 'Invite'

    expect(page).to have_content("Member was successfully invited.")
  end

  def update_my_account(attributes = {})
    visit edit_member_registration_path(attributes[:community])

    attributes[:notifications] ||= []

    fill_in 'First name',  with: attributes[:first_name] if attributes[:first_name]
    fill_in 'Last name',  with: attributes[:last_name] if attributes[:last_name]

    attributes[:notifications].each do |notification|
      uncheck notification
    end

    click_button 'Update'

    expect(page).to have_content("Your account has been updated successfully.")
  end

  def cancel_my_account(community)
    visit edit_member_registration_path(community)

    click_link 'Cancel your account'

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
