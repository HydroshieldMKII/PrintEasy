# frozen_string_literal: true

require 'test_helper'

class UserSubmissionControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @contest = contests(:contest_one)
    @submission = submissions(:submission_one)
    sign_in @user
  end

  test 'should get index' do
    assert_difference('Submission.count', 0) do
      get api_contest_user_submission_index_url(contest_id: @contest.id)
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal @parsed_response['submissions'][0]['submissions'].length, @contest.submissions.length
    assert_equal @parsed_response['submissions'][0]['submissions'][0]['user_id'], @contest.submissions[0].user_id
    assert_equal @parsed_response['submissions'][0]['submissions'][0]['contest_id'], @contest.submissions[0].contest_id
    assert_equal @parsed_response['submissions'][0]['submissions'][0]['name'], @contest.submissions[0].name
    assert_equal @parsed_response['submissions'][0]['submissions'][0]['description'],
                 @contest.submissions[0].description
    assert_equal @parsed_response['submissions'][0]['submissions'][0]['created_at'],
                 @contest.submissions[0].created_at.iso8601(3)
    assert_equal @parsed_response['submissions'][0]['submissions'][0]['updated_at'],
                 @contest.submissions[0].updated_at.iso8601(3)
    assert_equal @parsed_response['submissions'][0]['submissions'][0]['stl_url'].split('/').last,
                 @contest.submissions[0].stl.filename.to_s
    assert_equal @parsed_response['submissions'][0]['submissions'][0]['image_url'].split('/').last,
                 @contest.submissions[0].image.filename.to_s
  end

  test 'should return 404 for non-existent submission' do
    assert_difference('Submission.count', 0) do
      get api_contest_user_submission_index_url(contest_id: 0)
    end

    assert_response :not_found

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["Couldn't find Contest with 'id'=0 [WHERE `contests`.`deleted_at` IS NULL]"], @parsed_response['errors']['base']
  end

  test 'should return true if submission is liked by current user' do
    assert_difference('Submission.count', 0) do
      get api_contest_user_submission_index_url(contest_id: @contest.id)
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal @parsed_response['submissions'][0]['submissions'][0]['liked_by_current_user'], true
  end

  test 'should return false if submission is not liked by current user' do
    sign_out @user
    sign_in users(:two)
    assert_difference('Submission.count', 0) do
      get api_contest_user_submission_index_url(contest_id: @contest.id)
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal @parsed_response['submissions'][0]['submissions'][0]['liked_by_current_user'], false
  end

  test 'should return 401 for unauthorized user' do
    sign_out @user

    assert_difference('Submission.count', 0) do
      get api_contest_user_submission_index_url(contest_id: @contest.id)
    end

    assert_response :unauthorized

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ['Invalid login credentials'], @parsed_response['errors']['connection']
  end
end
