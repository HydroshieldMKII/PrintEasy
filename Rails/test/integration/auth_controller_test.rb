require "test_helper"

class AuthControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
  end

  test "should sign up" do
    post users_sign_up_path, params: { user: { username: "test", password: "password", password_confirmation: "password" } }

    assert_response :success
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal "test", @parsed_response["user"]["username"]
  end

  test "should sign in" do
    sign_out users(:one)
    post user_session_path, params: { user: { username: users(:two).username, password: "password" } }

    assert_response :success
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal users(:two).username, @parsed_response["user"]["username"]

  end

  test "should sign out" do
    delete destroy_user_session_path

    assert_response :success
  end

  # ------------ DOES NOT WORK ------------
  
  test "should not sign up -> no user" do
    post users_sign_up_path, params: {}

    assert_response :bad_request
    p response.body
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    p @parsed_response
  end
end