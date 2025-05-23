# frozen_string_literal: true

require 'test_helper'

class ContestControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in users(:two)
  end

  test 'should get index' do
    assert_difference('Contest.count', 0) do
      get api_contest_index_url
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :success

    assert_equal 3, @parsed_response['contests'].count

    assert_equal contests(:contest_four).id, @parsed_response['contests'][0]['id']
    assert_equal contests(:contest_four).theme, @parsed_response['contests'][0]['theme']
    assert_equal contests(:contest_four).description, @parsed_response['contests'][0]['description']
    assert_equal contests(:contest_four).submission_limit, @parsed_response['contests'][0]['submission_limit']
    assert_equal contests(:contest_four).start_at, @parsed_response['contests'][0]['start_at']
    assert_equal contests(:contest_four).end_at, @parsed_response['contests'][0]['end_at']
    assert_equal contests(:contest_four).deleted_at, @parsed_response['contests'][0]['deleted_at']
    assert_equal contests(:contest_four).image_url, @parsed_response['contests'][0]['image_url']

    assert_equal contests(:contest_five).id, @parsed_response['contests'][1]['id']
    assert_equal contests(:contest_five).theme, @parsed_response['contests'][1]['theme']
    assert_equal contests(:contest_five).description, @parsed_response['contests'][1]['description']
    assert_equal contests(:contest_five).submission_limit, @parsed_response['contests'][1]['submission_limit']
    assert_equal contests(:contest_five).start_at, @parsed_response['contests'][1]['start_at']
    assert_equal contests(:contest_five).end_at, @parsed_response['contests'][1]['end_at']
    assert_equal contests(:contest_five).deleted_at, @parsed_response['contests'][1]['deleted_at']
    assert_equal contests(:contest_five).image_url, @parsed_response['contests'][1]['image_url']
  end

  test 'should get show' do
    assert_difference('Contest.count', 0) do
      get api_contest_url(contests(:contest_one).id)
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :success

    assert_equal contests(:contest_one).id, @parsed_response['contest']['id']
    assert_equal contests(:contest_one).theme, @parsed_response['contest']['theme']
    assert_equal contests(:contest_one).description, @parsed_response['contest']['description']
    assert_equal contests(:contest_one).submission_limit, @parsed_response['contest']['submission_limit']
    assert_equal contests(:contest_one).start_at, @parsed_response['contest']['start_at']
    assert_equal contests(:contest_one).end_at, @parsed_response['contest']['end_at']
    assert_equal contests(:contest_one).deleted_at, @parsed_response['contest']['deleted_at']
    assert_equal contests(:contest_one).image_url, @parsed_response['contest']['image_url']
  end

  test 'should create contest' do
    assert_difference('Contest.count', 1) do
      post api_contest_index_url,
           params: { contest: { theme: 'test', description: 'test', submission_limit: 10, start_at: Time.now + 1.day,
                                image: fixture_file_upload(
                                  Rails.root.join('test/fixtures/files/chicken_bagel.jpg'), 'image/jpg'
                                ) } }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :success

    assert_equal 'test', @parsed_response['contest']['theme']
    assert_equal 'test', @parsed_response['contest']['description']
    assert_equal 10, @parsed_response['contest']['submission_limit']
    assert_equal (Time.now + 1.day).change(sec: 0),
                 @parsed_response['contest']['start_at'].to_datetime.change(sec: 0)
    assert_nil @parsed_response['contest']['end_at']
    assert_nil @parsed_response['contest']['deleted_at']
    assert_not_nil @parsed_response['contest']['image_url']
  end

  test 'should update contest' do
    assert_difference('Contest.count', 0) do
      put api_contest_url(contests(:contest_one).id),
          params: { contest: { theme: 'test', description: 'test', submission_limit: 10, start_at: Time.now + 2.day,
                               end_at: Time.now + 4.day,
                               image: fixture_file_upload(
                                 Rails.root.join('test/fixtures/files/chicken_bagel.jpg'), 'image/jpg'
                               ) } }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :success

    assert_equal 'test', @parsed_response['contest']['theme']
    assert_equal 'test', @parsed_response['contest']['description']
    assert_equal 10, @parsed_response['contest']['submission_limit']
    assert_equal (Time.now + 2.day).change(sec: 0),
                 @parsed_response['contest']['start_at'].to_datetime.change(sec: 0)
    assert_equal (Time.now + 4.day).change(sec: 0), @parsed_response['contest']['end_at'].to_datetime.change(sec: 0)
    assert_nil @parsed_response['contest']['deleted_at']
    assert_not_nil @parsed_response['contest']['image_url']
  end

  test 'should soft delete contest' do
    assert_difference('Contest.count', -1) do
      delete api_contest_url(contests(:contest_four).id)
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :success

    assert_not_nil @parsed_response['contest']['deleted_at']
    assert_equal Time.now.change(sec: 0), @parsed_response['contest']['deleted_at'].to_datetime.change(sec: 0)
    assert_equal contests(:contest_four).id, @parsed_response['contest']['id']
  end

  test 'should not get show -> contest not found' do
    assert_difference('Contest.count', 0) do
      get api_contest_url(0)
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :not_found
    assert_equal ["Couldn't find Contest with 'id'=0 [WHERE `contests`.`deleted_at` IS NULL]"],
                 @parsed_response['errors']['base']
  end

  test 'should not update contest -> contest not found' do
    assert_difference('Contest.count', 0) do
      put api_contest_url(0),
          params: { contest: { theme: 'test', description: 'test', submission_limit: 10, start_at: Time.now + 2.day,
                               end_at: Time.now + 4.day,
                               image: fixture_file_upload(
                                 Rails.root.join('test/fixtures/files/chicken_bagel.jpg'), 'image/jpg'
                               ) } }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :not_found
    assert_equal ["Couldn't find Contest with 'id'=0 [WHERE `contests`.`deleted_at` IS NULL]"],
                 @parsed_response['errors']['base']
  end

  test 'should not destroy contest -> contest not found' do
    assert_difference('Contest.count', 0) do
      delete api_contest_url(0)
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :not_found
    assert_equal ["Couldn't find Contest with 'id'=0 [WHERE `contests`.`deleted_at` IS NULL]"],
                 @parsed_response['errors']['base']
  end

  test 'should not create contest -> no contest' do
    assert_difference('Contest.count', 0) do
      post api_contest_index_path, params: {}
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :unprocessable_entity
    assert_equal ['param is missing or the value is empty or invalid: contest'], @parsed_response['errors']['base']
  end

  test 'should not create contest -> no theme' do
    assert_difference('Contest.count', 0) do
      post api_contest_index_path,
           params: { contest: { description: 'test', submission_limit: 10, start_at: Time.now + 1.day,
                                image: fixture_file_upload(
                                  Rails.root.join('test/fixtures/files/chicken_bagel.jpg'), 'image/jpg'
                                ) } }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :unprocessable_entity
    assert_equal ["can't be blank"], @parsed_response['errors']['theme']
  end

  test 'should not create contest -> description too long' do
    assert_difference('Contest.count', 0) do
      post api_contest_index_path,
           params: { contest: { theme: 'test', description: 'a' * 201, submission_limit: 10, start_at: Time.now + 1.day,
                                image: fixture_file_upload(
                                  Rails.root.join('test/fixtures/files/chicken_bagel.jpg'), 'image/jpg'
                                ) } }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :unprocessable_entity
    @parsed_response['errors']['description']
    assert_equal ['is too long (maximum is 200 characters)'], @parsed_response['errors']['description']
  end

  test 'should create contest -> no submisson limit' do
    assert_difference('Contest.count', 1) do
      post api_contest_index_path,
           params: { contest: { theme: 'test', description: 'test', start_at: Time.now + 1.day,
                                image: fixture_file_upload(
                                  Rails.root.join('test/fixtures/files/chicken_bagel.jpg'), 'image/jpg'
                                ) } }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :success

    assert_equal 1, @parsed_response['contest']['submission_limit']
  end

  test 'should not create contest -> no image' do
    assert_difference('Contest.count', 0) do
      post api_contest_index_path,
           params: { contest: { theme: 'test', description: 'test', submission_limit: 10,
                                start_at: Time.now + 1.day } }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :unprocessable_entity
    assert_equal ["can't be blank"], @parsed_response['errors']['image']
  end

  test 'should not update contest -> no contest' do
    assert_difference('Contest.count', 0) do
      put api_contest_url(contests(:contest_one).id), params: {}
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :unprocessable_entity
    assert_equal ['param is missing or the value is empty or invalid: contest'], @parsed_response['errors']['base']
  end

  test 'should not update contest -> theme empty' do
    assert_difference('Contest.count', 0) do
      put api_contest_url(contests(:contest_one).id),
          params: { contest: { theme: '', description: 'test', submission_limit: 10, start_at: Time.now + 1.day,
                               image: fixture_file_upload(
                                 Rails.root.join('test/fixtures/files/chicken_bagel.jpg'), 'image/jpg'
                               ) } }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :unprocessable_entity
    assert_equal ["can't be blank"], @parsed_response['errors']['theme']
  end

  test 'should not update contest -> description too long' do
    assert_difference('Contest.count', 0) do
      put api_contest_url(contests(:contest_one).id),
          params: { contest: { theme: 'test', description: 'a' * 201, submission_limit: 10, start_at: Time.now + 1.day,
                               image: fixture_file_upload(
                                 Rails.root.join('test/fixtures/files/chicken_bagel.jpg'), 'image/jpg'
                               ) } }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :unprocessable_entity
    assert_equal ['is too long (maximum is 200 characters)'], @parsed_response['errors']['description']
  end

  test 'should not update contest -> no image' do
    assert_difference('Contest.count', 0) do
      put api_contest_url(contests(:contest_one).id),
          params: { contest: { theme: 'test', description: 'test', submission_limit: 10, start_at: Time.now + 1.day,
                               image: nil } }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :unprocessable_entity
    assert_equal ["can't be blank"], @parsed_response['errors']['image']
  end

  test 'should not create contest -> start_at in the past' do
    assert_difference('Contest.count', 0) do
      post api_contest_index_path,
           params: { contest: { theme: 'test', description: 'test', submission_limit: 10, start_at: Time.now - 1.day,
                                image: fixture_file_upload(
                                  Rails.root.join('test/fixtures/files/chicken_bagel.jpg'), 'image/jpg'
                                ) } }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :unprocessable_entity
    assert_equal ['must be in the future'], @parsed_response['errors']['start_at']
  end

  test 'should not create contest -> end_at before start_at' do
    assert_difference('Contest.count', 0) do
      post api_contest_index_path,
           params: { contest: { theme: 'test', description: 'test', submission_limit: 10, start_at: Time.now + 1.day,
                                end_at: Time.now,
                                image: fixture_file_upload(
                                  Rails.root.join('test/fixtures/files/chicken_bagel.jpg'), 'image/jpg'
                                ) } }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :unprocessable_entity
    assert_equal ['must be before end_at'], @parsed_response['errors']['start_at']
  end

  test 'should not update contest -> start_at in the past' do
    assert_difference('Contest.count', 0) do
      put api_contest_url(contests(:contest_one).id),
          params: { contest: { theme: 'test', description: 'test', submission_limit: 10, start_at: Time.now - 1.day,
                               image: fixture_file_upload(
                                 Rails.root.join('test/fixtures/files/chicken_bagel.jpg'), 'image/jpg'
                               ) } }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :unprocessable_entity
    assert_equal ['must be in the future'], @parsed_response['errors']['start_at']
  end

  test 'should not update contest -> end_at before start_at' do
    assert_difference('Contest.count', 0) do
      put api_contest_url(contests(:contest_one).id),
          params: { contest: { theme: 'test', description: 'test', submission_limit: 10, start_at: Time.now + 1.day,
                               end_at: Time.now,
                               image: fixture_file_upload(
                                 Rails.root.join('test/fixtures/files/chicken_bagel.jpg'), 'image/jpg'
                               ) } }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :unprocessable_entity
    assert_equal ['must be before end_at'], @parsed_response['errors']['start_at']
  end

  test 'should not show contest if deleted -> contest found' do
    assert_difference('Contest.count', -1) do
      delete api_contest_url(contests(:contest_one).id)
    end

    sign_in users(:two) # ? Why is this necessary?

    assert_difference('Contest.count', 0) do
      get api_contest_url(contests(:contest_one).id)
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :not_found
    assert_equal ["Couldn't find Contest with 'id'=1 [WHERE `contests`.`deleted_at` IS NULL]"],
                 @parsed_response['errors']['base']
  end

  test 'should not update contest -> contest deleted' do
    assert_difference('Contest.count', -1) do
      delete api_contest_url(contests(:contest_one).id)
    end

    sign_in users(:two) # ? Why is this necessary?

    assert_difference('Contest.count', 0) do
      put api_contest_url(contests(:contest_one).id),
          params: { contest: { theme: 'test', description: 'test', submission_limit: 10, start_at: Time.now + 2.day,
                               end_at: Time.now + 4.day,
                               image: fixture_file_upload(
                                 Rails.root.join('test/fixtures/files/chicken_bagel.jpg'), 'image/jpg'
                               ) } }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :not_found
    assert_equal ["Couldn't find Contest with 'id'=1 [WHERE `contests`.`deleted_at` IS NULL]"],
                 @parsed_response['errors']['base']
  end

  test 'should not destroy contest -> contest deleted' do
    assert_difference('Contest.count', -1) do
      delete api_contest_url(contests(:contest_one).id)
    end

    sign_in users(:two) # ? Why is this necessary?

    assert_difference('Contest.count', 0) do
      delete api_contest_url(contests(:contest_one).id)
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :not_found
    assert_equal ["Couldn't find Contest with 'id'=1 [WHERE `contests`.`deleted_at` IS NULL]"],
                 @parsed_response['errors']['base']
  end

  test 'should not create contest -> no start_at' do
    assert_difference('Contest.count', 0) do
      post api_contest_index_path,
           params: { contest: { theme: 'test', description: 'test', submission_limit: 10,
                                image: fixture_file_upload(
                                  Rails.root.join('test/fixtures/files/chicken_bagel.jpg'), 'image/jpg'
                                ) } }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :unprocessable_entity
    assert_equal ["can't be blank", 'must be in the future'], @parsed_response['errors']['start_at']
  end

  test 'should not update contest -> no start_at' do
    assert_difference('Contest.count', 0) do
      put api_contest_url(contests(:contest_one).id),
          params: { contest: { theme: 'test', description: 'test', start_at: '', submission_limit: 10,
                               image: fixture_file_upload(
                                 Rails.root.join('test/fixtures/files/chicken_bagel.jpg'), 'image/jpg'
                               ) } }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :unprocessable_entity
    assert_equal ["can't be blank", 'must be in the future', 'must be before end_at'],
                 @parsed_response['errors']['start_at']
  end

  test 'should not create contest -> not admin' do
    sign_out users(:two)
    sign_in users(:one)

    assert_difference('Contest.count', 0) do
      post api_contest_index_path,
           params: { contest: { theme: 'test', description: 'test', submission_limit: 10, start_at: Time.now + 1.day,
                                image: fixture_file_upload(
                                  Rails.root.join('test/fixtures/files/chicken_bagel.jpg'), 'image/jpg'
                                ) } }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :unauthorized
    assert_equal ['You must be an admin to perform this action'], @parsed_response['errors']['contest']
  end

  test 'should not update contest -> not admin' do
    sign_out users(:two)
    sign_in users(:one)

    assert_difference('Contest.count', 0) do
      put api_contest_url(contests(:contest_one).id),
          params: { contest: { theme: 'test', description: 'test', submission_limit: 10, start_at: Time.now + 2.day,
                               end_at: Time.now + 4.day,
                               image: fixture_file_upload(
                                 Rails.root.join('test/fixtures/files/chicken_bagel.jpg'), 'image/jpg'
                               ) } }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :unauthorized
    assert_equal ['You must be an admin to perform this action'], @parsed_response['errors']['contest']
  end

  test 'should not destroy contest -> not admin' do
    sign_out users(:two)
    sign_in users(:one)

    assert_difference('Contest.count', 0) do
      delete api_contest_url(contests(:contest_one).id)
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :unauthorized
    assert_equal ['You must be an admin to perform this action'], @parsed_response['errors']['contest']
  end

  test 'should not update contest -> contest finished' do
    assert_difference('Contest.count', 0) do
      put api_contest_url(contests(:contest_one).id),
          params: { contest: { theme: 'test', description: 'test', submission_limit: 10, start_at: Time.now - 1.day,
                               end_at: Time.now - 1.day,
                               image: fixture_file_upload(
                                 Rails.root.join('test/fixtures/files/chicken_bagel.jpg'), 'image/jpg'
                               ) } }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :unprocessable_entity

    assert_equal ['is closed'], @parsed_response['errors']['contest']
  end

  test 'index should return all contests expect deleted for admin user' do
    assert_difference('Contest.count', 0) do
      get api_contest_index_url
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :success

    assert_equal 3, @parsed_response['contests'].count
  end

  test 'index should not return all contests expect deleted for non-admin user' do
    sign_out users(:two)
    sign_in users(:one)

    assert_difference('Contest.count', 0) do
      get api_contest_index_url
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :success

    assert_equal 3, @parsed_response['contests'].count
  end

  test "should not soft delete contest if it's already deleted" do
    assert_difference('Contest.count', -1) do
      delete api_contest_url(contests(:contest_one).id)
    end

    sign_in users(:two) # ? Why is this necessary?

    assert_difference('Contest.count', 0) do
      delete api_contest_url(contests(:contest_one).id)
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :not_found

    assert_equal ["Couldn't find Contest with 'id'=1 [WHERE `contests`.`deleted_at` IS NULL]"], @parsed_response['errors']['base']
  end

  test 'should not index if not sign in' do
    sign_out users(:two)

    assert_difference('Contest.count', 0) do
      get api_contest_index_url
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :unauthorized

    assert_equal ['Invalid login credentials'], @parsed_response['errors']['connection']
  end

  test 'should not show if not sign in' do
    sign_out users(:two)

    assert_difference('Contest.count', 0) do
      get api_contest_url(contests(:contest_one).id)
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :unauthorized

    assert_equal ['Invalid login credentials'], @parsed_response['errors']['connection']
  end

  test 'should not create if not sign in' do
    sign_out users(:two)

    assert_difference('Contest.count', 0) do
      post api_contest_index_path,
           params: { contest: { theme: 'test', description: 'test', submission_limit: 10, start_at: Time.now + 1.day,
                                image: fixture_file_upload(
                                  Rails.root.join('test/fixtures/files/chicken_bagel.jpg'), 'image/jpg'
                                ) } }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :unauthorized

    assert_equal ['Invalid login credentials'], @parsed_response['errors']['connection']
  end

  test 'should not update if not sign in' do
    sign_out users(:two)

    assert_difference('Contest.count', 0) do
      put api_contest_url(contests(:contest_one).id),
          params: { contest: { theme: 'test', description: 'test', submission_limit: 10, start_at: Time.now + 2.day,
                               end_at: Time.now + 4.day,
                               image: fixture_file_upload(
                                 Rails.root.join('test/fixtures/files/chicken_bagel.jpg'), 'image/jpg'
                               ) } }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :unauthorized

    assert_equal ['Invalid login credentials'], @parsed_response['errors']['connection']
  end

  test 'should not destroy if not sign in' do
    sign_out users(:two)

    assert_difference('Contest.count', 0) do
      delete api_contest_url(contests(:contest_one).id)
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :unauthorized

    assert_equal ['Invalid login credentials'], @parsed_response['errors']['connection']
  end

  test "should destroy contest if it's not started" do
    assert_difference('Contest.count', -1) do
      delete api_contest_url(contests(:contest_one).id)
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :success

    assert_nil @parsed_response['contest']['deleted_at']
    assert_equal contests(:contest_one).id, @parsed_response['contest']['id']
  end

  test 'should filter contest by finished' do
    assert_difference('Contest.count', 0) do
      get api_contest_index_url, params: { finished: true }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :success

    assert_equal 1, @parsed_response['contests'].count
    assert Time.now > @parsed_response['contests'][0]['end_at'].to_datetime
  end

  test 'should filter contest by active' do
    assert_difference('Contest.count', 0) do
      get api_contest_index_url, params: { active: true }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :success

    assert_equal 2, @parsed_response['contests'].count
    assert Time.now < @parsed_response['contests'][0]['end_at'].to_datetime
    assert Time.now < @parsed_response['contests'][1]['end_at'].to_datetime
  end

  test 'should filter by participants' do
    assert_difference('Contest.count', 0) do
      get api_contest_index_url, params: { participants_min: 1, participants_max: 1 }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :success

    assert_equal 2, @parsed_response['contests'].count
    assert_equal 1, @parsed_response['contests'][0]['submissions'].map { |s| s['user_id'] }.uniq.count
    assert_equal 1, @parsed_response['contests'][1]['submissions'].map { |s| s['user_id'] }.uniq.count
  end

  test 'should sort by submissions asc' do
    assert_difference('Contest.count', 0) do
      get api_contest_index_url, params: { sort_by_submissions: 'asc' }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :success

    assert_equal 3, @parsed_response['contests'].count
    assert_equal 0, @parsed_response['contests'][0]['submissions'].count
    assert_equal 1, @parsed_response['contests'][1]['submissions'].count
    assert_equal 1, @parsed_response['contests'][2]['submissions'].count
  end

  test 'should sort by submissions desc' do
    assert_difference('Contest.count', 0) do
      get api_contest_index_url, params: { sort_by_submissions: 'desc' }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :success

    assert_equal 3, @parsed_response['contests'].count
    assert_equal 1, @parsed_response['contests'][0]['submissions'].count
    assert_equal 1, @parsed_response['contests'][1]['submissions'].count
    assert_equal 0, @parsed_response['contests'][2]['submissions'].count
  end

  test 'should sort by date asc' do
    assert_difference('Contest.count', 0) do
      get api_contest_index_url, params: { sort: 'asc', category: 'start_at' }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :success

    assert_equal 3, @parsed_response['contests'].count
    assert @parsed_response['contests'][0]['start_at'].to_datetime <= @parsed_response['contests'][1]['start_at'].to_datetime
    assert @parsed_response['contests'][1]['start_at'].to_datetime <= @parsed_response['contests'][2]['start_at'].to_datetime
    assert_equal true, @parsed_response['contests'][2]['finished?']
  end

  test 'should sort by date desc' do
    assert_difference('Contest.count', 0) do
      get api_contest_index_url, params: { sort: 'desc', category: 'start_at' }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :success

    assert_equal 3, @parsed_response['contests'].count
    assert @parsed_response['contests'][0]['start_at'].to_datetime >= @parsed_response['contests'][1]['start_at'].to_datetime
    assert @parsed_response['contests'][1]['start_at'].to_datetime <= @parsed_response['contests'][2]['start_at'].to_datetime
    assert_equal true, @parsed_response['contests'][2]['finished?']
  end

  test 'should sort by default category if wrong category' do
    assert_difference('Contest.count', 0) do
      get api_contest_index_url, params: { sort: 'asc', category: 'start' }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :success

    assert_equal 3, @parsed_response['contests'].count
    assert @parsed_response['contests'][0]['start_at'].to_datetime <= @parsed_response['contests'][1]['start_at'].to_datetime
    assert @parsed_response['contests'][1]['start_at'].to_datetime <= @parsed_response['contests'][2]['start_at'].to_datetime
    assert_equal true, @parsed_response['contests'][2]['finished?']
  end

  test 'should sort by default asc if wrong sort' do
    assert_difference('Contest.count', 0) do
      get api_contest_index_url, params: { sort: 'wrong', category: 'start_at' }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :success

    assert_equal 3, @parsed_response['contests'].count
    assert @parsed_response['contests'][0]['start_at'].to_datetime <= @parsed_response['contests'][1]['start_at'].to_datetime
    assert @parsed_response['contests'][1]['start_at'].to_datetime <= @parsed_response['contests'][2]['start_at'].to_datetime
    assert_equal true, @parsed_response['contests'][2]['finished?']
  end

  test 'should sort by default desc if wrong sort_by_submissions' do
    assert_difference('Contest.count', 0) do
      get api_contest_index_url, params: { sort_by_submissions: 'wrong' }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :success

    assert_equal 3, @parsed_response['contests'].count
    assert_equal 1, @parsed_response['contests'][0]['submissions'].count
    assert_equal 1, @parsed_response['contests'][1]['submissions'].count
    assert_equal 0, @parsed_response['contests'][2]['submissions'].count
  end

  test 'should not filter by participants if wrong participants parameters' do
    assert_difference('Contest.count', 0) do
      get api_contest_index_url, params: { participant: 1 }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :success

    assert_equal 3, @parsed_response['contests'].count
  end

  test 'should not filter by finished if wrong finished parameters' do
    assert_difference('Contest.count', 0) do
      get api_contest_index_url, params: { finish: true }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :success

    assert_equal 3, @parsed_response['contests'].count
  end

  test 'should not filter by active if wrong active parameters' do
    assert_difference('Contest.count', 0) do
      get api_contest_index_url, params: { actives: true }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :success

    assert_equal 3, @parsed_response['contests'].count
  end

  test 'should search by theme' do
    assert_difference('Contest.count', 0) do
      get api_contest_index_url, params: { search: 'test' }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :success

    assert_equal 3, @parsed_response['contests'].count
  end

  test 'should not search by theme if wrong search parameters' do
    assert_difference('Contest.count', 0) do
      get api_contest_index_url, params: { searchs: 'test' }
    end

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_response :success

    assert_equal 3, @parsed_response['contests'].count
  end
end
