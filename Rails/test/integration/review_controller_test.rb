# frozen_string_literal: true

require 'test_helper'

class ReviewControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
  end

  test 'should get review show' do
    sign_in users(:one)
    assert_difference('Review.count', 0) do
      get api_review_url(1), as: :json
    end

    assert_response :ok
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal 1, @parsed_response['review']['id']
    assert_equal 6, @parsed_response['review']['order_id']
    assert_equal 1, @parsed_response['review']['user_id']
    assert_equal 3, @parsed_response['review']['rating']
    assert_equal 'Review 1', @parsed_response['review']['title']
    assert_equal 'This is the first review', @parsed_response['review']['description']
    assert_empty @parsed_response['errors']
  end

  test 'should not get review show -> not logged in' do
    assert_difference('Review.count', 0) do
      get api_review_url(1), as: :json
    end

    assert_response :unauthorized
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['Invalid login credentials'], @parsed_response['errors']['connection']
  end

  test 'should not get review show -> does not exist' do
    sign_in users(:one)
    assert_difference('Review.count', 0) do
      get api_review_url(999), as: :json
    end

    assert_response :not_found
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Couldn't find Review with 'id'=999"], @parsed_response['errors']['base']
  end

  #-----------------------------------------------------------------------------

  test 'should create review from Cancelled' do
    sign_in users(:one)
    assert_difference('Review.count', 1) do
      post api_review_index_path,
           params: { review: {
             order_id: 7,
             rating: 3,
             title: 'Review 1',
             description: 'This is the first review',
             user_id: 2
           } }, as: :json
    end

    assert_response :created
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal 1, @parsed_response['review']['user_id']
    assert_equal 7, @parsed_response['review']['order_id']
    assert_equal 3, @parsed_response['review']['rating']
    assert_equal 'Review 1', @parsed_response['review']['title']
    assert_equal 'This is the first review', @parsed_response['review']['description']
    assert_empty @parsed_response['errors']
  end

  test 'should create review from Arrived' do
    sign_in users(:one)
    assert_difference('Review.count', 1) do
      post api_review_index_path,
           params: { review: { order_id: 5, rating: 3, title: 'Review 1', description: 'This is the first review' } }, as: :json
    end

    assert_response :created
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal 1, @parsed_response['review']['user_id']
    assert_equal 5, @parsed_response['review']['order_id']
    assert_equal 3, @parsed_response['review']['rating']
    assert_equal 'Review 1', @parsed_response['review']['title']
    assert_equal 'This is the first review', @parsed_response['review']['description']
    assert_empty @parsed_response['errors']
  end

  test 'should not create review -> Accepted' do
    sign_in users(:one)
    assert_difference('Review.count', 0) do
      post api_review_index_path,
           params: { review: { order_id: 1, rating: 3, title: 'Review 1', description: 'This is the first review' } }, as: :json
    end

    assert_response :bad_request
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['Order status does not permit review'], @parsed_response['errors']['order_id']
  end

  test 'should not create review -> Printing' do
    sign_in users(:one)
    assert_difference('Review.count', 0) do
      post api_review_index_path,
           params: { review: { order_id: 2, rating: 3, title: 'Review 1', description: 'This is the first review' } }, as: :json
    end

    assert_response :bad_request
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['Order status does not permit review'], @parsed_response['errors']['order_id']
  end

  test 'should not create review -> Printed' do
    sign_in users(:one)
    assert_difference('Review.count', 0) do
      post api_review_index_path,
           params: { review: { order_id: 3, rating: 3, title: 'Review 1', description: 'This is the first review' } }, as: :json
    end

    assert_response :bad_request
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['Order status does not permit review'], @parsed_response['errors']['order_id']
  end

  test 'should not create review -> Shipped' do
    sign_in users(:one)
    assert_difference('Review.count', 0) do
      post api_review_index_path,
           params: { review: { order_id: 4, rating: 3, title: 'Review 1', description: 'This is the first review' } }, as: :json
    end

    assert_response :bad_request
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['Order status does not permit review'], @parsed_response['errors']['order_id']
  end

  test 'should not create review -> not logged in' do
    assert_difference('Review.count', 0) do
      post api_review_index_path,
           params: { review: { order_id: 7, rating: 3, title: 'Review 1', description: 'This is the first review' } }, as: :json
    end

    assert_response :unauthorized
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['Invalid login credentials'], @parsed_response['errors']['connection']
  end

  test 'should not create review -> invalid order_id' do
    sign_in users(:one)
    assert_difference('Review.count', 0) do
      post api_review_index_path,
           params: { review: { order_id: 999, rating: 3, title: 'Review 1', description: 'This is the first review' } }, as: :json
    end

    assert_response :bad_request
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['must exist'], @parsed_response['errors']['order']
  end

  test 'should not create review -> invalid rating too much' do
    sign_in users(:one)
    assert_difference('Review.count', 0) do
      post api_review_index_path,
           params: { review: { order_id: 7, rating: 6, title: 'Review 1', description: 'This is the first review' } }, as: :json
    end

    assert_response :bad_request
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['must be less than or equal to 5'], @parsed_response['errors']['rating']
  end

  test 'should not create review -> invalid rating not enough' do
    sign_in users(:one)
    assert_difference('Review.count', 0) do
      post api_review_index_path,
           params: { review: { order_id: 7, rating: -1, title: 'Review 1', description: 'This is the first review' } }, as: :json
    end

    assert_response :bad_request
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['must be greater than or equal to 0'], @parsed_response['errors']['rating']
  end

  test 'should not create review -> invalid title not enough' do
    sign_in users(:one)
    assert_difference('Review.count', 0) do
      post api_review_index_path,
           params: { review: { order_id: 7, rating: 3, title: 'R', description: 'This is the first review' } }, as: :json
    end

    assert_response :bad_request
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['is too short (minimum is 5 characters)'], @parsed_response['errors']['title']
  end

  test 'should not create review -> invalid title too much' do
    sign_in users(:one)
    assert_difference('Review.count', 0) do
      post api_review_index_path,
           params: { review: {
             order_id: 7,
             rating: 3,
             title: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa',
             description: 'This is the first review'
           } }, as: :json
    end

    assert_response :bad_request
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['is too long (maximum is 30 characters)'], @parsed_response['errors']['title']
  end

  test 'should not create review -> invalid description not enough' do
    sign_in users(:one)
    assert_difference('Review.count', 0) do
      post api_review_index_path,
           params: { review: { order_id: 7, rating: 3, title: 'Review 1', description: 'This' } }, as: :json
    end

    assert_response :bad_request
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['is too short (minimum is 5 characters)'], @parsed_response['errors']['description']
  end

  test 'should not create review -> invalid description too much' do
    sign_in users(:one)
    assert_difference('Review.count', 0) do
      post api_review_index_path,
           params: { review: {
             order_id: 7,
             rating: 3,
             title: 'Review 1',
             description: 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa
             aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
           } }, as: :json
    end

    assert_response :bad_request
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['is too long (maximum is 200 characters)'], @parsed_response['errors']['description']
  end

  test 'should not create review -> order does not belong to user' do
    sign_in users(:two)
    assert_difference('Review.count', 0) do
      post api_review_index_path,
           params: { review: { order_id: 7, rating: 3, title: 'Review 1', description: 'This is the first review' } }, as: :json
    end

    assert_response :bad_request
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['Order does not belong to the user'], @parsed_response['errors']['order_id']
  end

  test 'should not create review -> already has a review' do
    sign_in users(:one)
    assert_difference('Review.count', 0) do
      post api_review_index_path,
           params: { review: { order_id: 6, rating: 3, title: 'Review 1', description: 'This is the first review' } }, as: :json
    end

    assert_response :bad_request
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['has already been taken'], @parsed_response['errors']['order_id']
  end

  #-----------------------------------------------------------------------------

  test "should update review (also check that you can't change user or order)" do
    sign_in users(:one)
    assert_difference('Review.count', 0) do
      patch api_review_url(1),
            params: { review: {
              rating: 2,
              title: 'Review 2',
              description: 'This is the second review',
              order_id: 5,
              user_id: 2
            } }, as: :json
    end

    assert_response :ok
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal 1, @parsed_response['review']['user_id']
    assert_equal 6, @parsed_response['review']['order_id']
    assert_equal 2, @parsed_response['review']['rating']
    assert_equal 'Review 2', @parsed_response['review']['title']
    assert_equal 'This is the second review', @parsed_response['review']['description']
    assert_empty @parsed_response['errors']
  end

  test 'should not update review -> not logged in' do
    assert_difference('Review.count', 0) do
      patch api_review_url(1),
            params: { review: { rating: 2, title: 'Review 2', description: 'This is the second review' } }, as: :json
    end

    assert_response :unauthorized
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['Invalid login credentials'], @parsed_response['errors']['connection']
  end

  test 'should not update review -> does not exist' do
    sign_in users(:one)
    assert_difference('Review.count', 0) do
      patch api_review_url(999),
            params: { review: { rating: 2, title: 'Review 2', description: 'This is the second review' } }, as: :json
    end

    assert_response :not_found
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Couldn't find Review with 'id'=999 [WHERE `reviews`.`user_id` = ?]"],
                 @parsed_response['errors']['base']
  end

  test 'should not update review -> not owner' do
    sign_in users(:two)
    assert_difference('Review.count', 0) do
      patch api_review_url(1),
            params: { review: { rating: 2, title: 'Review 2', description: 'This is the second review' } }, as: :json
    end

    assert_response :not_found
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Couldn't find Review with 'id'=1 [WHERE `reviews`.`user_id` = ?]"],
                 @parsed_response['errors']['base']
  end

  #-----------------------------------------------------------------------------

  test 'should destroy review' do
    sign_in users(:one)
    assert_difference('Review.count', -1) do
      delete api_review_url(1), as: :json
    end

    assert_response :ok
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_empty @parsed_response['errors']
  end

  test 'should not destroy review -> not logged in' do
    assert_difference('Review.count', 0) do
      delete api_review_url(1), as: :json
    end

    assert_response :unauthorized
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['Invalid login credentials'], @parsed_response['errors']['connection']
  end

  test 'should not destroy review -> does not exist' do
    sign_in users(:one)
    assert_difference('Review.count', 0) do
      delete api_review_url(999), as: :json
    end

    assert_response :not_found
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Couldn't find Review with 'id'=999 [WHERE `reviews`.`user_id` = ?]"],
                 @parsed_response['errors']['base']
  end

  test 'should not destroy review -> not owner' do
    sign_in users(:two)
    assert_difference('Review.count', 0) do
      delete api_review_url(1), as: :json
    end

    assert_response :not_found
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Couldn't find Review with 'id'=1 [WHERE `reviews`.`user_id` = ?]"],
                 @parsed_response['errors']['base']
  end
end
