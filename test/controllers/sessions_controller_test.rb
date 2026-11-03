require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  test "pages need a signed in user" do
    get root_path
    assert_redirected_to new_session_path
  end

  test "signing in with the right password" do
    sign_in_as
    assert_redirected_to root_path
    follow_redirect!
    assert_select "h1", "Dashboard"
  end

  test "wrong password is refused" do
    User.create!(name: "Ngozi Eze", email: "ngozi@okoroestates.ng", password: "rentroll2026")
    post session_path, params: { email: "ngozi@okoroestates.ng", password: "nope" }
    assert_response :unprocessable_content
  end
end
