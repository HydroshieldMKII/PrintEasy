# frozen_string_literal: true

require 'test_helper'

class OrderControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
  end

  test 'should get index' do
    sign_in users(:one)

    assert_difference('Order.count', 0) do
      get api_order_index_path, as: :json
    end

    assert_response :success
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal 7, @parsed_response['orders'].length
    tested_order = @parsed_response['orders'][0]
    test_order(tested_order)
    assert_empty @parsed_response['errors']
  end

  test 'should get index -> status filter' do
    sign_in users(:one)

    assert_difference('Order.count', 0) do
      get '/api/order/?filter=Accepted', as: :json
    end

    assert_response :success
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal 1, @parsed_response['orders'].length
    tested_order = @parsed_response['orders'][0]
    assert_empty @parsed_response['errors']
    test_order(tested_order)
  end

  test 'should get index -> review filter' do
    sign_in users(:one)

    assert_difference('Order.count', 0) do
      get '/api/order/?filter=notReviewed', as: :json
    end

    assert_response :success
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal 6, @parsed_response['orders'].length
    tested_order = @parsed_response['orders'][0]
    assert_empty @parsed_response['errors']
    test_order(tested_order)
  end

  test 'should get index -> search filter' do
    sign_in users(:one)

    assert_difference('Order.count', 0) do
      get '/api/order/?search=test', as: :json
    end

    assert_response :success
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal 7, @parsed_response['orders'].length
    tested_order = @parsed_response['orders'][0]
    assert_empty @parsed_response['errors']
    test_order(tested_order)
  end

  test 'should get index -> sort filter' do
    sign_in users(:one)

    assert_difference('Order.count', 0) do
      get '/api/order/?sort=date-desc', as: :json
    end

    assert_response :success
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal 7, @parsed_response['orders'].length
    tested_order = @parsed_response['orders'][0]
    assert_empty @parsed_response['errors']
    test_order(tested_order)
  end

  test 'should get show' do
    sign_in users(:one)

    assert_difference('Order.count', 0) do
      get api_order_path(1), as: :json
    end

    assert_response :success
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    test_order(@parsed_response['order'])
    assert_empty @parsed_response['errors']
  end

  test "should not get show -> doesn't exit" do
    sign_in users(:one)

    assert_difference('Order.count', 0) do
      get api_order_path(999), as: :json
    end

    assert_response :not_found
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Couldn't find Order with 'id'=999 [WHERE (requests.user_id = ? OR printer_users.user_id = ?)]"],
                 @parsed_response['errors']['base']
  end

  test 'should not get show -> not owner' do
    sign_in users(:three)

    assert_difference('Order.count', 0) do
      get api_order_path(1), as: :json
    end

    assert_response :not_found
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Couldn't find Order with 'id'=1 [WHERE (requests.user_id = ? OR printer_users.user_id = ?)]"],
                 @parsed_response['errors']['base']
  end

  test 'should not get index -> not signed in' do
    assert_difference('Order.count', 0) do
      get api_order_index_path, as: :json
    end

    assert_response :unauthorized
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['Invalid login credentials'], @parsed_response['errors']['connection']
  end

  test 'should not get show -> not signed in' do
    assert_difference('Order.count', 0) do
      get api_order_path(1), as: :json
    end

    assert_response :unauthorized
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['Invalid login credentials'], @parsed_response['errors']['connection']
  end

  test 'should not get create -> not signed in' do
    assert_difference('Order.count', 0) do
      post api_order_index_path, params: { id: 1 }, as: :json
    end

    assert_response :unauthorized
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['Invalid login credentials'], @parsed_response['errors']['connection']
  end

  test 'should not get create -> offer_id missing' do
    sign_in users(:one)

    assert_difference('Order.count', 0) do
      post api_order_index_path, as: :json
    end

    assert_response :unprocessable_entity
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['must exist'], @parsed_response['errors']['offer']
    assert_equal [
      "can't be blank",
      'Offer must exist',
      'Consumer and printer cannot be the same user',
      'User is not owner of request'
    ], @parsed_response['errors']['offer_id']
  end

  test "should not get create -> offer_id doesn't exist" do
    sign_in users(:one)

    assert_difference('Order.count', 0) do
      post api_order_index_path, params: { id: 999 }, as: :json
    end

    assert_response :unprocessable_entity
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['must exist'], @parsed_response['errors']['offer']
  end

  test "shouldn't create order -> user is not owner of request" do
    sign_in users(:one)

    assert_difference('Order.count', 0) do
      post api_order_index_path, params: { id: 2 }, as: :json
    end

    assert_response :unprocessable_entity
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['User is not owner of request'], @parsed_response['errors']['offer_id']
  end

  test 'should not create order -> offer_id already used' do
    sign_in users(:one)

    assert_difference('Order.count', 0) do
      post api_order_index_path, params: { id: 1 }, as: :json
    end

    assert_response :unprocessable_entity
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['has already been taken', 'Request already has an order'], @parsed_response['errors']['offer_id']
  end

  test 'should not create order -> request_id already used' do
    sign_in users(:one)

    assert_difference('Order.count', 0) do
      post api_order_index_path, params: { id: 3 }, as: :json
    end

    assert_response :unprocessable_entity
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ['has already been taken', 'Request already has an order'], @parsed_response['errors']['offer_id']
  end

  test 'should create order' do
    sign_in users(:two)

    assert_difference('Order.count', 1) do
      post api_order_index_path, params: { id: 9 }, as: :json
    end

    assert_response :created
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal 9, @parsed_response['order']['offer']['id']
    assert_empty @parsed_response['errors']
  end

  private

  def test_order(tested_order)
    assert_nil tested_order['offer_id']
    assert_equal offers(:one).id, tested_order['offer']['id']
    assert_equal offers(:one).print_quality, tested_order['offer']['print_quality'].to_f
    assert_equal offers(:one).price, tested_order['offer']['price']
    assert_nil tested_order['offer']['created_at']
    assert_nil tested_order['offer']['updated_at']
    assert_nil tested_order['offer']['printer_user_id']
    assert_nil tested_order['offer']['request_id']
    assert_nil tested_order['offer']['color_id']
    assert_nil tested_order['offer']['filament_id']

    assert_equal offers(:one).printer_user.id, tested_order['offer']['printer_user']['id']
    assert_equal offers(:one).printer_user.acquired_date.strftime('%a, %d %b %Y'),
                 Date.parse(tested_order['offer']['printer_user']['acquired_date']).strftime('%a, %d %b %Y')
    assert_nil tested_order['offer']['printer_user']['printer_id']
    assert_nil tested_order['offer']['printer_user']['user_id']

    assert_equal offers(:one).printer_user.user.id, tested_order['offer']['printer_user']['user']['id']
    assert_equal offers(:one).printer_user.user.username, tested_order['offer']['printer_user']['user']['username']
    assert_nil tested_order['offer']['printer_user']['user']['profile_picture_url']
    assert_nil tested_order['offer']['printer_user']['user']['country_id']

    assert_equal offers(:one).printer_user.user.country.id, tested_order['offer']['printer_user']['user']['country']['id']
    assert_equal offers(:one).printer_user.user.country.name, tested_order['offer']['printer_user']['user']['country']['name']

    assert_equal offers(:one).printer_user.printer.id, tested_order['offer']['printer_user']['printer']['id']
    assert_equal offers(:one).printer_user.printer.model, tested_order['offer']['printer_user']['printer']['model']

    assert_equal offers(:one).request.id, tested_order['offer']['request']['id']
    assert_equal offers(:one).request.budget, tested_order['offer']['request']['budget']
    assert_equal offers(:one).request.target_date.strftime('%a, %d %b %Y'),
                 Date.parse(tested_order['offer']['request']['target_date']).strftime('%a, %d %b %Y')
    assert_equal offers(:one).request.comment, tested_order['offer']['request']['comment']
    assert_nil tested_order['offer']['request']['created_at']
    assert_nil tested_order['offer']['request']['updated_at']
    assert_nil tested_order['offer']['request']['user_id']

    assert_equal offers(:one).request.user.id, tested_order['offer']['request']['user']['id']
    assert_equal offers(:one).request.user.username, tested_order['offer']['request']['user']['username']
    assert_nil tested_order['offer']['request']['user']['profile_picture_url']
    assert_nil tested_order['offer']['request']['user']['country_id']

    assert_equal offers(:one).request.user.country.id, tested_order['offer']['request']['user']['country']['id']
    assert_equal offers(:one).request.user.country.name, tested_order['offer']['request']['user']['country']['name']

    assert_equal offers(:one).request.preset_requests[0].id, tested_order['offer']['request']['preset_requests'][0]['id']
    assert_equal offers(:one).request.preset_requests[0].print_quality,
                 tested_order['offer']['request']['preset_requests'][0]['print_quality'].to_f

    assert_equal offers(:one).request.preset_requests[0].color.id,
                 tested_order['offer']['request']['preset_requests'][0]['color']['id']
    assert_equal offers(:one).request.preset_requests[0].color.name,
                 tested_order['offer']['request']['preset_requests'][0]['color']['name']

    assert_equal offers(:one).request.preset_requests[0].filament.id,
                 tested_order['offer']['request']['preset_requests'][0]['filament']['id']
    assert_equal offers(:one).request.preset_requests[0].filament.name,
                 tested_order['offer']['request']['preset_requests'][0]['filament']['name']

    assert_equal offers(:one).request.preset_requests[0].printer.id,
                 tested_order['offer']['request']['preset_requests'][0]['printer']['id']
    assert_equal offers(:one).request.preset_requests[0].printer.model,
                 tested_order['offer']['request']['preset_requests'][0]['printer']['model']

    assert_equal offers(:one).color.id, tested_order['offer']['color']['id']
    assert_equal offers(:one).color.name, tested_order['offer']['color']['name']

    assert_equal offers(:one).filament.id, tested_order['offer']['filament']['id']
    assert_equal offers(:one).filament.name, tested_order['offer']['filament']['name']

    assert_equal 1, tested_order['order_status'].length
    tested_order_status = tested_order['order_status'][0]
    assert_nil tested_order_status['order_id']
    assert_equal order_status(:one).id, tested_order_status['id']
    assert_equal order_status(:one).status_name, tested_order_status['status_name']
    assert_equal order_status(:one).comment, tested_order_status['comment']
    assert_equal order_status(:one).created_at, tested_order_status['created_at']
    assert_equal order_status(:one).updated_at, tested_order_status['updated_at']
  end
end
