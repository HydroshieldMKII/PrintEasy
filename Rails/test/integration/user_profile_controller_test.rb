# frozen_string_literal: true

require 'test_helper'

class UserProfileControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  def setup
    @user = users(:one)

    sign_in @user
  end

  test "should get show" do
    assert_difference 'User.count', 0 do
      get api_user_profile_path(@user)
    end

    assert_response :success

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal @user.id, json_response['user']['id']
    assert_equal 'James Bond', json_response['user']['username']
    assert_equal 'Canada', json_response['user']['country']['name']
    assert_equal 1, json_response['user']['country']['id']
    assert_equal 1, json_response['user']['printer_users'].length
    printer_user = json_response['user']['printer_users'][0]
    assert_equal 1, printer_user['id']
    assert_equal '2025-02-14', printer_user['acquired_date']
    assert_nil printer_user['last_review_image']
    assert_nil printer_user['last_used']
    assert_equal false, printer_user['can_update']
    assert_equal 1, printer_user['printer']['id']
    assert_equal 'Bambulab', printer_user['printer']['model']
    assert_equal 1, printer_user['user']['id']
  end

  test "should not get show if not signed in" do
    sign_out @user

    assert_difference 'User.count', 0 do
      get api_user_profile_path(@user)
    end

    assert_response :unauthorized

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal ["Invalid login credentials"], json_response['errors']["connection"]
  end
end
