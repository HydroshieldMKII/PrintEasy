# frozen_string_literal: true

require 'test_helper'

class UserContestSubmissionsControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  setup do
    @user = users(:one)
    sign_in @user
  end

  test 'should get index' do
    assert_difference('Contest.count', 0) do
      get api_user_contest_submissions_url
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response['contests'].length
  end

  test 'should return 404 for non-existent user' do
    sign_out @user

    assert_difference('Contest.count', 0) do
      get api_user_contest_submissions_url
    end

    assert_response :unauthorized

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ['Invalid login credentials'], @parsed_response['errors']['connection']
  end

  test "should not get index if user is not logged in" do
    sign_out @user

    assert_difference('Contest.count', 0) do
      get api_user_contest_submissions_url
    end

    assert_response :unauthorized

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ['Invalid login credentials'], @parsed_response['errors']['connection']
  end
end
