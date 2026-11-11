require "application_system_test_case"

class SessionsSystemTest < ApplicationSystemTestCase
  test "login page renders without navigation chrome" do
    visit new_session_path

    # Page title and heading present
    assert_selector "h1", text: "Log in"

    # Auth layout renders only auth UI — no sidebar, no nav, no user menu
    assert_no_selector "aside#sidebar"
    assert_no_selector "nav"
    assert_no_selector "[aria-label='Main navigation']"
    assert_no_selector ".sidebar-link"
    assert_no_selector ".sidebar-brand"

    # Auth card is centered
    assert_selector ".auth-card"
    assert_selector "form[action='/login']"

    # Form fields have required attributes and autocomplete hints
    assert_selector "input[type='email'][autocomplete='username'][required]"
    assert_selector "input[type='password'][autocomplete='current-password'][required]"

    # Password toggle present and accessible
    assert_selector "button[aria-label='Show password']", count: 1
  end

  test "login page shows error flash on invalid credentials" do
    visit new_session_path

    fill_in "Email address", with: "nonexistent@example.com"
    fill_in "Password", with: "wrongpassword"
    click_on "Log in"

    assert_selector "div[role='alert']", text: /Invalid email or password/
  end
end
