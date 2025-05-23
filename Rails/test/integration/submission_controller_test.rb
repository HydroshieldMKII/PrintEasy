# frozen_string_literal: true

require 'test_helper'

class SubmissionControllerTest < ActionDispatch::IntegrationTest
  setup do
    @contest = contests(:contest_one)
    @submission = submissions(:submission_one)
    @user = users(:one)
    @stl_file = active_storage_blobs(:first_stl_file_blob)
    @image_file = active_storage_blobs(:first_image_blob)
    sign_in @user
  end

  test 'should get index' do
    assert_difference('Submission.count', 0) do
      get api_submission_index_url, params: { submission: { contest_id: @contest.id } }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal @contest.submissions.count, @parsed_response['submissions'].count
    assert_equal @contest.submissions.first.name, @parsed_response['submissions'].first['name']
    assert_equal @contest.submissions.first.description, @parsed_response['submissions'].first['description']
    assert_equal @contest.submissions.first.stl_url, @parsed_response['submissions'].first['stl_url']
    assert_equal @contest.submissions.first.image_url, @parsed_response['submissions'].first['image_url']
    assert_equal @contest.submissions.first.likes.count, @parsed_response['submissions'].first['likes'].count
  end

  test 'should show submission' do
    assert_difference('Submission.count', 0) do
      get api_submission_url(@submission)
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal @submission.name, @parsed_response['submission']['name']
    assert_equal @submission.description, @parsed_response['submission']['description']
    assert_equal @submission.stl_url, @parsed_response['submission']['stl_url']
    assert_equal @submission.image_url, @parsed_response['submission']['image_url']
    assert_equal @submission.likes.count, @parsed_response['submission']['likes'].count
  end

  test 'should create submission' do
    assert_difference('Submission.count') do
      post api_submission_index_url,
           params: { submission: { contest_id: contests(:contest_four).id, name: 'New Submission',
                                   description: 'New Description',
                                   stl: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type),
                                   image: fixture_file_upload(@image_file.filename.to_s, @image_file.content_type) } }
    end
    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 'New Submission', @parsed_response['submission']['name']
    assert_equal 'New Description', @parsed_response['submission']['description']
    assert_equal 4, @parsed_response['submission']['contest_id']
    assert_equal @user.id, @parsed_response['submission']['user_id']
    assert_not_equal nil, @parsed_response['submission']['stl_url']
    assert_equal 'RUBY13.stl', @parsed_response['submission']['stl_url'].split('/').last
    assert_equal 'chicken_bagel.jpg', @parsed_response['submission']['image_url'].split('/').last
  end

  test 'should update submission' do
    assert_difference('Submission.count', 0) do
      patch api_submission_url(@submission),
            params: { submission: { contest_id: @contest.id, name: 'Updated Submission', description: 'Updated Description',
                                    stl: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type),
                                    image: fixture_file_upload(@image_file.filename.to_s, @image_file.content_type) } }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 'Updated Submission', @parsed_response['submission']['name']
    assert_equal 'Updated Description', @parsed_response['submission']['description']
    assert_not_equal nil, @parsed_response['submission']['stl_url']
    assert_equal 'RUBY13.stl', @parsed_response['submission']['stl_url'].split('/').last
    assert_not_equal nil, @parsed_response['submission']['image_url']
    assert_equal 'chicken_bagel.jpg', @parsed_response['submission']['image_url'].split('/').last
  end

  test 'should destroy submission' do
    assert_difference('Submission.count', -1) do
      delete api_submission_url(@submission)
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal @submission.id, @parsed_response['submission']['id']
    assert_equal 0, @parsed_response['submission']['likes'].count
  end

  test 'should not create submission without name' do
    assert_difference('Submission.count', 0) do
      post api_submission_index_url,
           params: { submission: { contest_id: @contest.id, description: 'New Description',
                                   stl: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type),
                                   image: fixture_file_upload(@image_file.filename.to_s, @image_file.content_type) } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["can't be blank", 'is too short (minimum is 3 characters)'], @parsed_response['errors']['name']
  end

  test 'should not create submission without contest_id' do
    assert_difference('Submission.count', 0) do
      post api_submission_index_url,
           params: { submission: { name: 'New Submission', description: 'New Description',
                                   stl: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type),
                                   image: fixture_file_upload(@image_file.filename.to_s, @image_file.content_type) } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ['must exist', "can't be blank"], @parsed_response['errors']['contest']
  end

  test 'should not create submission without image and stl' do
    assert_difference('Submission.count', 0) do
      post api_submission_index_url,
           params: { submission: { contest_id: @contest.id, name: 'New Submission', description: 'New Description' } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["can't be blank"], @parsed_response['errors']['image']
    assert_equal ["can't be blank"], @parsed_response['errors']['stl']
  end

  test 'should not create submission with invalid image format' do
    assert_difference('Submission.count', 0) do
      post api_submission_index_url,
           params: { submission: { user_id: @user.id, contest_id: @contest.id, name: 'New Submission',
                                   description: 'New Description',
                                   image: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type),
                                   stl: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type) } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ['must be a PNG, JPG, or JPEG file'], @parsed_response['errors']['image']
  end

  test 'should not update submission without name' do
    assert_difference('Submission.count', 0) do
      patch api_submission_url(@submission),
            params: { submission: { contest_id: @contest.id, name: '', description: 'Updated Description',
                                    stl: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type),
                                    image: fixture_file_upload(@image_file.filename.to_s, @image_file.content_type) } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["can't be blank", 'is too short (minimum is 3 characters)'], @parsed_response['errors']['name']
  end

  test 'should not update submission without contest_id' do
    assert_difference('Submission.count', 0) do
      patch api_submission_url(@submission),
            params: { submission: { contest_id: nil, name: 'Updated Submission', description: 'Updated Description',
                                    stl: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type),
                                    image: fixture_file_upload(@image_file.filename.to_s, @image_file.content_type) } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ['must exist', "can't be blank"], @parsed_response['errors']['contest']
  end

  test 'should not update submission without image and stl' do
    assert_difference('Submission.count', 0) do
      patch api_submission_url(@submission),
            params: { submission: { user_id: @user.id, contest_id: @contest.id, name: 'Updated Submission',
                                    description: 'Updated Description',
                                    image: nil,
                                    stl: nil } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["can't be blank"], @parsed_response['errors']['stl']
    assert_equal ["can't be blank"], @parsed_response['errors']['image']
  end

  test 'should not update submission with no image and stl' do
    assert_difference('Submission.count', 0) do
      patch api_submission_url(@submission),
            params: { submission: { user_id: @user.id, contest_id: @contest.id, name: 'Updated Submission',
                                    description: 'Updated Description',
                                    image: nil,
                                    stl: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type) } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["can't be blank"], @parsed_response['errors']['image']
  end

  test 'should not update with no stl and image' do
    assert_difference('Submission.count', 0) do
      patch api_submission_url(@submission),
            params: { submission: { user_id: @user.id, contest_id: @contest.id, name: 'Updated Submission',
                                    description: 'Updated Description',
                                    image: fixture_file_upload(@image_file.filename.to_s, @image_file.content_type),
                                    stl: nil } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["can't be blank"], @parsed_response['errors']['stl']
  end

  test 'should not create submission with no stl and image' do
    assert_difference('Submission.count', 0) do
      post api_submission_index_url,
           params: { submission: { user_id: @user.id, contest_id: @contest.id, name: 'New Submission',
                                   description: 'New Description',
                                   image: fixture_file_upload(@image_file.filename.to_s, @image_file.content_type),
                                   stl: nil } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["can't be blank"], @parsed_response['errors']['stl']
  end

  test 'should not create submission with invalid stl format' do
    assert_difference('Submission.count', 0) do
      post api_submission_index_url,
           params: { submission: { user_id: @user.id, contest_id: @contest.id, name: 'New Submission',
                                   description: 'New Description',
                                   stl: fixture_file_upload(@image_file.filename.to_s, @image_file.content_type),
                                   image: fixture_file_upload(@image_file.filename.to_s, @image_file.content_type) } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ['must have .stl extension'], @parsed_response['errors']['stl']
  end

  test 'should not create a submission with invalid image format' do
    assert_difference('Submission.count', 0) do
      post api_submission_index_url,
           params: { submission: { user_id: @user.id, contest_id: @contest.id, name: 'New Submission',
                                   description: 'New Description',
                                   stl: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type),
                                   image: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type) } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ['must be a PNG, JPG, or JPEG file'], @parsed_response['errors']['image']
  end

  test 'should not update submission with invalid stl format' do
    assert_difference('Submission.count', 0) do
      patch api_submission_url(@submission),
            params: { submission: { user_id: @user.id, contest_id: @contest.id, name: 'Updated Submission',
                                    description: 'Updated Description',
                                    stl: fixture_file_upload(@image_file.filename.to_s, @image_file.content_type),
                                    image: fixture_file_upload(@image_file.filename.to_s, @image_file.content_type) } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ['must have .stl extension'], @parsed_response['errors']['stl']
  end

  test 'should not update submission with invalid image format' do
    assert_difference('Submission.count', 0) do
      patch api_submission_url(@submission),
            params: { submission: { user_id: @user.id, contest_id: @contest.id, name: 'Updated Submission',
                                    description: 'Updated Description',
                                    stl: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type),
                                    image: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type) } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ['must be a PNG, JPG, or JPEG file'], @parsed_response['errors']['image']
  end

  test 'should not update submission with invalid contest_id' do
    assert_difference('Submission.count', 0) do
      patch api_submission_url(@submission),
            params: { submission: { contest_id: 9, name: 'Updated Submission', description: 'Updated Description',
                                    stl: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type),
                                    image: fixture_file_upload(@image_file.filename.to_s, @image_file.content_type) } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ['must exist', "can't be blank"], @parsed_response['errors']['contest']
  end

  test 'should not destroy submission with invalid id' do
    assert_difference('Submission.count', 0) do
      delete api_submission_url(9), params: { submission: { user_id: @user.id } }
    end

    assert_response :not_found

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["Couldn't find Submission with 'id'=9 [WHERE `submissions`.`user_id` = ?]"], @parsed_response['errors']['base']
  end

  test 'should not update submission with invalid id' do
    assert_difference('Submission.count', 0) do
      patch api_submission_url(9),
            params: { submission: { contest_id: @contest.id, name: 'Updated Submission', description: 'Updated Description',
                                    stl: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type),
                                    image: fixture_file_upload(@image_file.filename.to_s, @image_file.content_type) } }
    end

    assert_response :not_found

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["Couldn't find Submission with 'id'=9 [WHERE `submissions`.`user_id` = ?]"], @parsed_response['errors']['base']
  end

  test 'should not update submission with invalid user' do
    sign_out @user
    sign_in users(:two)

    assert_difference('Submission.count', 0) do
      patch api_submission_url(@submission),
            params: { submission: { contest_id: @contest.id, name: 'Updated Submission', description: 'Updated Description',
                                    stl: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type),
                                    image: fixture_file_upload(@image_file.filename.to_s, @image_file.content_type) } }
    end

    assert_response :not_found

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["Couldn't find Submission with 'id'=1 [WHERE `submissions`.`user_id` = ?]"], @parsed_response['errors']['base']
  end

  test 'should not destroy submission with invalid user' do
    sign_out @user
    sign_in users(:two)

    assert_difference('Submission.count', 0) do
      delete api_submission_url(@submission)
    end

    assert_response :not_found

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["Couldn't find Submission with 'id'=1 [WHERE `submissions`.`user_id` = ?]"], @parsed_response['errors']['base']
  end

  test 'should not destroy submission without login' do
    sign_out @user

    assert_difference('Submission.count', 0) do
      delete api_submission_url(@submission)
    end

    assert_response :unauthorized

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ['Invalid login credentials'], @parsed_response['errors']['connection']
  end

  test 'should not update submission without login' do
    sign_out @user

    assert_difference('Submission.count', 0) do
      patch api_submission_url(@submission),
            params: { submission: { user_id: @user.id, contest_id: @contest.id, name: 'Updated Submission',
                                    description: 'Updated Description',
                                    stl: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type),
                                    image: fixture_file_upload(@image_file.filename.to_s, @image_file.content_type) } }
    end

    assert_response :unauthorized

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ['Invalid login credentials'], @parsed_response['errors']['connection']
  end

  test 'should not create submission without login' do
    sign_out @user

    assert_difference('Submission.count', 0) do
      post api_submission_index_url,
           params: { submission: { user_id: @user.id, contest_id: @contest.id, name: 'New Submission',
                                   description: 'New Description',
                                   stl: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type),
                                   image: fixture_file_upload(@image_file.filename.to_s, @image_file.content_type) } }
    end

    assert_response :unauthorized

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ['Invalid login credentials'], @parsed_response['errors']['connection']
  end

  test 'should not show submission without login' do
    sign_out @user

    assert_difference('Submission.count', 0) do
      get api_submission_url(@submission)
    end

    assert_response :unauthorized

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ['Invalid login credentials'], @parsed_response['errors']['connection']
  end

  test 'should not get index without login' do
    sign_out @user

    assert_difference('Submission.count', 0) do
      get api_submission_index_url, params: { submission: { contest_id: @contest.id } }
    end

    assert_response :unauthorized

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ['Invalid login credentials'], @parsed_response['errors']['connection']
  end

  test 'should not get index without contest_id' do
    assert_difference('Submission.count', 0) do
      get api_submission_index_url
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ['param is missing or the value is empty or invalid: submission'], @parsed_response['errors']['base']
  end

  test 'should not show submission without id' do
    assert_difference('Submission.count', 0) do
      get api_submission_url(9)
    end

    assert_response :not_found

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["Couldn't find Submission with 'id'=9 [WHERE `submissions`.`user_id` = ?]"], @parsed_response['errors']['base']
  end

  test 'should not update submission without id' do
    assert_difference('Submission.count', 0) do
      patch api_submission_url(9),
            params: { submission: { contest_id: @contest.id, name: 'Updated Submission',
                                    description: 'Updated Description',
                                    stl: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type),
                                    image: fixture_file_upload(@image_file.filename.to_s, @image_file.content_type) } }
    end

    assert_response :not_found

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["Couldn't find Submission with 'id'=9 [WHERE `submissions`.`user_id` = ?]"], @parsed_response['errors']['base']
  end

  test 'should not destroy submission without id' do
    assert_difference('Submission.count', 0) do
      delete api_submission_url(9)
    end

    assert_response :not_found

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["Couldn't find Submission with 'id'=9 [WHERE `submissions`.`user_id` = ?]"], @parsed_response['errors']['base']
  end

  test 'should not create submission if submission limit is reached' do
    assert_difference('Submission.count', 0) do
      post api_submission_index_url,
           params: { submission: { contest_id: contests(:contest_five).id, name: 'New Submission',
                                   description: 'New Description',
                                   stl: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type),
                                   image: fixture_file_upload(@image_file.filename.to_s, @image_file.content_type) } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ['has reached the submission limit for this contest'], @parsed_response['errors']['submission']
  end

  test 'should not create submission if contest is closed' do
    assert_difference('Submission.count', 0) do
      post api_submission_index_url,
           params: { submission: { contest_id: contests(:contest_three).id, name: 'New Submission',
                                   description: 'New Description',
                                   stl: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type),
                                   image: fixture_file_upload(@image_file.filename.to_s, @image_file.content_type) } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ['is closed'], @parsed_response['errors']['contest']
  end

  test 'should not update submission if contest is closed' do
    assert_difference('Submission.count', 0) do
      patch api_submission_url(submissions(:submission_three)),
            params: { submission:
                      {
                        contest_id: contests(:contest_three).id, name: 'Updated Submission',
                        description: 'Updated Description',
                        stl: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type),
                        image: fixture_file_upload(@image_file.filename.to_s, @image_file.content_type)
                      } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ['is closed'], @parsed_response['errors']['contest']
  end

  test 'should not update submission if contest is finished' do
    assert_difference('Submission.count', 0) do
      patch api_submission_url(submissions(:submission_four)),
            params: { submission: { contest_id: contests(:contest_three).id,
                                    name: 'Updated Submission',
                                    description: 'Updated Description',
                                    stl: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type),
                                    image: fixture_file_upload(@image_file.filename.to_s,
                                                               @image_file.content_type) } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ['is closed'], @parsed_response['errors']['contest']
  end

  test 'should not create submission if contest is finished' do
    assert_difference('Submission.count', 0) do
      post api_submission_index_url,
           params: { submission: { contest_id: contests(:contest_three).id, name: 'New Submission',
                                   description: 'New Description',
                                   stl: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type),
                                   image: fixture_file_upload(@image_file.filename.to_s, @image_file.content_type) } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ['is closed'], @parsed_response['errors']['contest']
  end

  test 'should not create submission if contest is not started' do
    assert_difference('Submission.count', 0) do
      post api_submission_index_url,
           params: { submission: { contest_id: contests(:contest_two).id, name: 'New Submission',
                                   description: 'New Description',
                                   stl: fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type),
                                   image: fixture_file_upload(@image_file.filename.to_s, @image_file.content_type) } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ['has not started yet'], @parsed_response['errors']['contest']
  end

  test 'should not delete submission if contest is closed' do
    assert_difference('Submission.count', 0) do
      delete api_submission_url(submissions(:submission_three))
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ['is closed'], @parsed_response['errors']['contest']
  end
end
