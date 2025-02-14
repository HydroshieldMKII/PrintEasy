require "test_helper"

class AuthControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
  end

  test "should sign up" do
    assert_difference('User.count', 1) do
      post user_registration_path, params: { user: { username: "test", password: "password", password_confirmation: "password", country_id: countries(:one).id } }
    end

    assert_response :success
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal countries(:one).id, @parsed_response["user"]["country_id"]
    assert_equal "test", @parsed_response["user"]["username"]
  end

  test "should sign in" do
    sign_out users(:one)
    assert_difference('User.count', 0) do
      post user_session_path, params: { user: { username: users(:two).username, password: "password" } }
    end

    assert_response :success
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal users(:two).username, @parsed_response["user"]["username"]
    assert_equal users(:two).country_id, @parsed_response["user"]["country_id"]

  end

  test "should sign out" do
    assert_difference('User.count', 0) do
      delete destroy_user_session_path
    end

    assert_response :success
  end

  # ------------ DOES NOT WORK ------------
  
  # Sign up
  test "should not sign up -> no user" do
    assert_difference('User.count', 0) do
      post user_registration_path, params: {}
    end

    assert_response :unprocessable_entity
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    
    assert_equal ["param is missing or the value is empty: user"], @parsed_response["errors"]["user"]
  end

  test "should not sign up -> no username" do
    assert_difference('User.count', 0) do
      post user_registration_path, params: { user: { password: "password", password_confirmation: "password", country_id: countries(:one).id } }
    end

    assert_response :unprocessable_entity
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["can't be blank"], @parsed_response["errors"]["username"]
  end

  test "should not sign up -> no password" do
    assert_difference('User.count', 0) do
      post user_registration_path, params: { user: { username: "test", password_confirmation: "password", country_id: countries(:one).id } }
    end

    assert_response :unprocessable_entity
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["can't be blank"], @parsed_response["errors"]["password"]
  end

  test "should not sign up -> no password confirmation" do
    assert_difference('User.count', 0) do
      post user_registration_path, params: { user: { username: "test", password: "password", country_id: countries(:one).id } }
    end

    assert_response :unprocessable_entity
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["can't be blank"], @parsed_response["errors"]["password_confirmation"]
  end

  test "should not sign up -> no country" do
    assert_difference('User.count', 0) do
      post user_registration_path, params: { user: { username: "test", password: "password", password_confirmation: "password" } }
    end

    assert_response :unprocessable_entity
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["must exist"], @parsed_response["errors"]["country"]
  end

  test "should not sign up -> password too short" do
    assert_difference('User.count', 0) do
      post user_registration_path, params: { user: { username: "test", password: "pass", password_confirmation: "pass", country_id: countries(:one).id } }
    end

    assert_response :unprocessable_entity
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["is too short (minimum is 6 characters)"], @parsed_response["errors"]["password"]
  end

  test "should not sign up -> country does not exist" do
    assert_difference('User.count', 0) do
      post user_registration_path, params: { user: { username: "test", password: "password", password_confirmation: "password", country_id: 0 } }
    end

    assert_response :unprocessable_entity
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["must exist"], @parsed_response["errors"]["country"]
  end

  test "should not sign up -> password and password confirmation do not match" do
    assert_difference('User.count', 0) do
      post user_registration_path, params: { user: { username: "test", password: "password", password_confirmation: "password1" } }
    end

    assert_response :unprocessable_entity
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["doesn't match Password"], @parsed_response["errors"]["password_confirmation"]
  end

  test "should not sign up -> username already taken" do
    assert_difference('User.count', 0) do
      post user_registration_path, params: { user: { username: users(:one).username, password: "password", password_confirmation: "password" } }
    end

    assert_response :unprocessable_entity
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["has already been taken"], @parsed_response["errors"]["username"]
  end

  test "should not sign up -> no password and confirm" do
    assert_difference('User.count', 0) do
      post user_registration_path, params: { user: { username: "test" } }
    end

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

    assert_difference('User.count', 0) do
      post user_session_path, params: {}
    end

    assert_response :unauthorized
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Invalid login credentials"], @parsed_response["errors"]["connection"]
  end

  test "should not sign in -> no username" do
    sign_out users(:one)

    assert_difference('User.count', 0) do
      post user_session_path, params: { user: { password: "password" } }
    end

    assert_response :unauthorized
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Invalid login credentials"], @parsed_response["errors"]["connection"]
  end

  test "should not sign in -> no password" do
    sign_out users(:one)

    assert_difference('User.count', 0) do
      post user_session_path, params: { user: { username: users(:two).username } }
    end

    assert_response :unauthorized
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Invalid login credentials"], @parsed_response["errors"]["connection"]
  end

  test "should not sign in -> wrong username" do
    sign_out users(:one)

    assert_difference('User.count', 0) do
      post user_session_path, params: { user: { username: "test", password: "password" } }
    end

    assert_response :unauthorized
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Invalid login credentials"], @parsed_response["errors"]["connection"]
  end

  test "should not sign in -> wrong password" do
    sign_out users(:one)

    assert_difference('User.count', 0) do
      post user_session_path, params: { user: { username: users(:two).username, password: "password1" } }
    end

    assert_response :unauthorized
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Invalid login credentials"], @parsed_response["errors"]["connection"]
  end

  # Sign out

  test "should not sign out -> not signed in" do
    sign_out users(:one)

    assert_difference('User.count', 0) do
      delete destroy_user_session_path
    end

    assert_response :unauthorized
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal "You need to sign in or sign up before continuing.", @parsed_response["errors"]
  end
end