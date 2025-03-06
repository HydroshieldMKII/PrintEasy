# frozen_string_literal: true

require 'test_helper'

class RequestsSsfControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user_request = requests(:request_one)
    @user_request2 = requests(:request_three)

    @other_user = users(:two)
    @other_user_request = requests(:request_two)

    @preset = preset_requests(:preset_request_one)
    @preset2 = preset_requests(:preset_request_two)

    sign_in @user
  end

  ### INDEX (SSF) ACTION ###

  test 'should sort requests by name in ascending order' do
    get api_request_index_url, params: { type: 'mine', sort: 'asc', sortCategory: 'name' }
    assert_response :success
    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 3, json_response['request'].length
    assert_equal 'Test Request', json_response['request'][0]['name']
    assert_equal 'Test Request 3', json_response['request'][1]['name']
    assert_equal 'Test Request 4', json_response['request'][2]['name']
  end

  test 'should sort requests by name in descending order' do
    get api_request_index_url, params: { type: 'mine', sort: 'desc', sortCategory: 'name' }
    assert_response :success
    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 3, json_response['request'].length
    assert_equal 'Test Request 4', json_response['request'][0]['name']
    assert_equal 'Test Request 3', json_response['request'][1]['name']
    assert_equal 'Test Request', json_response['request'][2]['name']
  end

  test 'should sort requests by budget in ascending order' do
    get api_request_index_url, params: { type: 'mine', sort: 'asc', sortCategory: 'budget' }
    assert_response :success
    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 3, json_response['request'].length
    assert_equal 100.0, json_response['request'][0]['budget']
    assert_equal 150.0, json_response['request'][1]['budget']
    assert_equal 250.0, json_response['request'][2]['budget']
  end

  test 'should sort requests by budget in descending order' do
    get api_request_index_url, params: { type: 'mine', sort: 'desc', sortCategory: 'budget' }
    assert_response :success
    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 3, json_response['request'].length
    assert_equal 250.0, json_response['request'][0]['budget']
    assert_equal 150.0, json_response['request'][1]['budget']
    assert_equal 100.0, json_response['request'][2]['budget']
  end

  test 'should sort requests by date in ascending order' do
    get api_request_index_url, params: { type: 'mine', sort: 'asc', sortCategory: 'date' }
    assert_response :success
    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 3, json_response['request'].length
    assert_equal '2021-10-31', json_response['request'][0]['target_date']
    assert_equal '2021-12-31', json_response['request'][1]['target_date']
    assert_equal '2021-12-31', json_response['request'][2]['target_date']
  end

  test 'should sort requests by date in descending order' do
    get api_request_index_url, params: { type: 'mine', sort: 'desc', sortCategory: 'date' }
    assert_response :success
    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 3, json_response['request'].length
    assert_equal '2021-12-31', json_response['request'][0]['target_date']
    assert_equal '2021-12-31', json_response['request'][1]['target_date']
    assert_equal '2021-10-31', json_response['request'][2]['target_date']
  end

  test 'should filter requests by in-progress status' do
    get api_request_index_url, params: { type: 'mine', filter: 'in-progress' }
    assert_response :success
    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert(json_response['request'].all? { |r| r['accepted_at'].present? })
    assert_equal 2, json_response['request'].length
  end

  test 'should filter requests by country' do
    get api_request_index_url, params: { type: 'mine', filter: 'country' }
    assert_response :success
    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 3, json_response['request'].length
    assert(json_response['request'].all? { |r| r['user']['country']['name'] == 'Canada' })
  end

  test 'should filter requests by budget range' do
    get api_request_index_url, params: { type: 'mine', minBudget: 120, maxBudget: 200 }
    assert_response :success
    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 1, json_response['request'].length
    assert(json_response['request'].all? { |r| r['budget'] >= 120 && r['budget'] <= 200 })
    assert_equal 150.0, json_response['request'][0]['budget']
  end

  test 'should filter requests by date range' do
    get api_request_index_url, params: {
      type: 'mine',
      startDate: '2021-12-01',
      endDate: '2021-12-31'
    }
    assert_response :success
    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 2, json_response['request'].length
    assert(json_response['request'].all? { |r| r['target_date'] == '2021-12-31' })
  end

  test 'should combine filtering and sorting' do
    get api_request_index_url, params: {
      type: 'mine',
      sort: 'desc',
      sortCategory: 'budget',
      minBudget: 50,
      maxBudget: 200
    }
    assert_response :success
    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 2, json_response['request'].length
    assert_equal 150.0, json_response['request'][0]['budget']
    assert_equal 100.0, json_response['request'][1]['budget']
  end

  test 'should handle search parameter' do
    get api_request_index_url, params: { type: 'mine', search: 'Test Request 3' }
    assert_response :success
    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 1, json_response['request'].length
    assert_equal 'Test Request 3', json_response['request'][0]['name']
  end
end
