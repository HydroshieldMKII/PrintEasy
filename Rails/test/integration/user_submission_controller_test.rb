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
      get api_user_submission_index_url, params: { submission: { contest_id: @contest.id } }
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

  test 'should show submission' do
    get api_user_submission_url(@submission)

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal @parsed_response['submission']['id'], @submission.id
    assert_equal @parsed_response['submission']['user_id'], @submission.user_id
    assert_equal @parsed_response['submission']['contest_id'], @submission.contest_id
    assert_equal @parsed_response['submission']['name'], @submission.name
    assert_equal @parsed_response['submission']['description'], @submission.description
    assert_equal @parsed_response['submission']['created_at'], @submission.created_at.iso8601(3)
    assert_equal @parsed_response['submission']['updated_at'], @submission.updated_at.iso8601(3)
    assert_equal @parsed_response['submission']['stl_url'].split('/').last, @submission.stl.filename.to_s
    assert_equal @parsed_response['submission']['image_url'].split('/').last, @submission.image.filename.to_s
  end

  test 'should return 404 for non-existent submission' do
    assert_difference('Submission.count', 0) do
      get api_user_submission_url(id: 0)
    end

    assert_response :not_found

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["Couldn't find Submission with 'id'=0"], @parsed_response['errors']["base"]
  end

  test "should return true if submission is liked by current user" do
    assert_difference('Submission.count', 0) do
      get api_user_submission_index_url, params: { submission: { contest_id: @contest.id } }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal @parsed_response["submissions"][0]["submissions"][0]["liked_by_current_user"], true
  end
end