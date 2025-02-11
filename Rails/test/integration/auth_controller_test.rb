require "test_helper"

class AuthControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
  end

  test "should sign up" do
    post user_registration_path, params: { user: { username: "test", password: "password", password_confirmation: "password" } }

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
  
  # Sign up
  test "should not sign up -> no user" do
    post user_registration_path, params: {}

    assert_response :unprocessable_entity
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    
    assert_equal ["param is missing or the value is empty: user"], @parsed_response["errors"]["user"]
  end

  test "should not sign up -> no username" do
    post user_registration_path, params: { user: { password: "password", password_confirmation: "password" } }

    assert_response :unprocessable_entity
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["can't be blank"], @parsed_response["errors"]["username"]
  end

  test "should not sign up -> no password" do
    post user_registration_path, params: { user: { username: "test", password_confirmation: "password" } }

    assert_response :unprocessable_entity
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["can't be blank"], @parsed_response["errors"]["password"]
  end

  test "should not sign up -> no password confirmation" do
    post user_registration_path, params: { user: { username: "test", password: "password" } }

    assert_response :unprocessable_entity
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["can't be blank"], @parsed_response["errors"]["password_confirmation"]
  end

  test "should not sign up -> password and password confirmation do not match" do
    post user_registration_path, params: { user: { username: "test", password: "password", password_confirmation: "password1" } }

    assert_response :unprocessable_entity
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["doesn't match Password"], @parsed_response["errors"]["password_confirmation"]
  end

  test "should not sign up -> username already taken" do
    post user_registration_path, params: { user: { username: users(:one).username, password: "password", password_confirmation: "password" } }

    assert_response :unprocessable_entity
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["has already been taken"], @parsed_response["errors"]["username"]
  end

  test "should not sign up -> no password and confirm" do
    post user_registration_path, params: { user: { username: "test" } }

    assert_response :unprocessable_entity
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["can't be blank"], @parsed_response["errors"]["password"]
    assert_equal ["can't be blank"], @parsed_response["errors"]["password_confirmation"]
  end

  # Sign in

  test "should not sign in -> no user" do
    sign_out users(:one)
    post user_session_path, params: {}

    assert_response :unauthorized
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Invalid login credentials"], @parsed_response["errors"]["connection"]
  end

  test "should not sign in -> no username" do
    sign_out users(:one)
    post user_session_path, params: { user: { password: "password" } }

    assert_response :unauthorized
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Invalid login credentials"], @parsed_response["errors"]["connection"]
  end

  test "should not sign in -> no password" do
    sign_out users(:one)
    post user_session_path, params: { user: { username: users(:two).username } }

    assert_response :unauthorized
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Invalid login credentials"], @parsed_response["errors"]["connection"]
  end

  test "should not sign in -> wrong username" do
    sign_out users(:one)
    post user_session_path, params: { user: { username: "test", password: "password" } }

    assert_response :unauthorized
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Invalid login credentials"], @parsed_response["errors"]["connection"]
  end

  test "should not sign in -> wrong password" do
    sign_out users(:one)
    post user_session_path, params: { user: { username: users(:two).username, password: "password1" } }

    assert_response :unauthorized
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Invalid login credentials"], @parsed_response["errors"]["connection"]
  end

  # Sign out

  test "should not sign out -> not signed in" do
    sign_out users(:one)
    delete destroy_user_session_path

    assert_response :unauthorized
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal "You need to sign in or sign up before continuing.", @parsed_response["errors"]
  end
end