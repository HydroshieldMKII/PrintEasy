# frozen_string_literal: true

require 'test_helper'

class OfferControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @offer = offers(:one)
    @offer2 = offers(:two)

    @other_user = users(:two)
    @other_offer = offers(:three)

    @other_user2 = users(:three)

    @request = requests(:request_three)

    sign_in @user
  end

  # INDEX
  test 'should get mine index' do
    # Database changes
    assert_no_difference 'Offer.count' do
      get api_offer_index_url, params: { type: 'mine' }
    end

    # Http code
    assert_response :success

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_equal 2, json_response['requests'][0]['offers'][0]['id']
    assert_equal 2.5, json_response['requests'][0]['offers'][0]['price']
    assert_equal '2021-01-02', json_response['requests'][0]['offers'][0]['target_date']
    assert_equal 0.22, json_response['requests'][0]['offers'][0]['print_quality']
    assert_nil json_response['requests'][0]['offers'][0]['cancelled_at']
    assert_equal 1, json_response['requests'][0]['offers'][0]['printer_user']['id']
    assert_equal 1, json_response['requests'][0]['offers'][0]['printer_user']['user']['id']
    assert_equal 'James Bond', json_response['requests'][0]['offers'][0]['printer_user']['user']['username']
    assert_equal 1, json_response['requests'][0]['offers'][0]['printer_user']['printer']['id']
    assert_equal 'Bambulab', json_response['requests'][0]['offers'][0]['printer_user']['printer']['model']
    assert_equal 2, json_response['requests'][0]['offers'][0]['color']['id']
    assert_equal 'Red', json_response['requests'][0]['offers'][0]['color']['name']
    assert_equal 2, json_response['requests'][0]['offers'][0]['filament']['id']
    assert_equal 'ABS', json_response['requests'][0]['offers'][0]['filament']['name']

    assert_equal 9, json_response['requests'][0]['offers'][1]['id']
    assert_equal 1.5, json_response['requests'][0]['offers'][1]['price']
    assert_equal '2021-01-01', json_response['requests'][0]['offers'][1]['target_date']
    assert_equal 0.22, json_response['requests'][0]['offers'][1]['print_quality']
    assert_nil json_response['requests'][0]['offers'][1]['cancelled_at']
    assert_equal 1, json_response['requests'][0]['offers'][1]['printer_user']['id']
    assert_equal 1, json_response['requests'][0]['offers'][1]['printer_user']['user']['id']
    assert_equal 'James Bond', json_response['requests'][0]['offers'][1]['printer_user']['user']['username']
    assert_equal 1, json_response['requests'][0]['offers'][1]['printer_user']['printer']['id']
    assert_equal 'Bambulab', json_response['requests'][0]['offers'][1]['printer_user']['printer']['model']
    assert_equal 1, json_response['requests'][0]['offers'][1]['color']['id']
    assert_equal 'Blue', json_response['requests'][0]['offers'][1]['color']['name']
    assert_equal 1, json_response['requests'][0]['offers'][1]['filament']['id']
    assert_equal 'PLA', json_response['requests'][0]['offers'][1]['filament']['name']

    assert_equal 2, json_response['requests'][0]['id']
    assert_equal 'Test Request 2', json_response['requests'][0]['name']
    assert_equal 200.0, json_response['requests'][0]['budget']
    assert_equal 'Test Comments 2', json_response['requests'][0]['comment']
    assert_equal '2021-12-31', json_response['requests'][0]['target_date']
    assert_equal 2, json_response['requests'][0]['user']['id']
    assert_equal 'John Doe', json_response['requests'][0]['user']['username']
  end

  test 'should get all index' do
    sign_out @user
    sign_in @other_user
    # Database changes
    assert_no_difference 'Offer.count' do
      get api_offer_index_url, params: { type: 'all' }
    end

    # Http code
    assert_response :success

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_equal 2, json_response['requests'][0]['id']
    assert_equal 'Test Request 2', json_response['requests'][0]['name']
    assert_equal 200.0, json_response['requests'][0]['budget']
    assert_equal 'Test Comments 2', json_response['requests'][0]['comment']
    assert_equal '2021-12-31', json_response['requests'][0]['target_date']
    assert_equal 2, json_response['requests'][0]['user']['id']
    assert_equal 'John Doe', json_response['requests'][0]['user']['username']

    assert_equal 2, json_response['requests'][0]['offers'][0]['id']
    assert_equal 2.5, json_response['requests'][0]['offers'][0]['price']
    assert_equal '2021-01-02', json_response['requests'][0]['offers'][0]['target_date']
    assert_equal 0.22, json_response['requests'][0]['offers'][0]['print_quality']
    assert_nil json_response['requests'][0]['offers'][0]['cancelled_at']

    assert_empty json_response['errors']
  end

  test 'index should return empty if unknown params' do
    # Database changes
    assert_no_difference 'Offer.count' do
      get api_offer_index_url, params: { type: 'invalid' }
    end

    # Http code
    assert_response :success

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_equal [], json_response['requests']
    assert_empty json_response['errors']
  end

  # CREATE

  test 'should create offer' do
    # Database changes
    assert_difference 'Offer.count' do
      post api_offer_index_url,
           params: { offer: { name: 'Test Offer', price: 1.5, target_date: '2026-01-01', comment: 'test comment',
                              request_id: offers(:nine).request_id, printer_user_id: @user.printer_user.first.id,
                              color_id: @offer2.color_id, filament_id: @offer.filament_id, print_quality: 0.22 } }
    end

    # Http code
    assert_response :success

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_not_nil json_response['offer']['id']
    assert_equal 2, json_response['offer']['request_id']
    assert_equal 1, json_response['offer']['printer_user_id']
    assert_equal 2, json_response['offer']['color_id']
    assert_equal 1, json_response['offer']['filament_id']
    assert_equal 1.5, json_response['offer']['price']
    assert_equal '2026-01-01', json_response['offer']['target_date']
    assert_equal 0.22, json_response['offer']['print_quality']
    assert_nil json_response['offer']['cancelled_at']
    assert_empty json_response['errors']
  end

  test 'should not create offer with base params' do
    # Database changes
    assert_no_difference 'Offer.count' do
      post api_offer_index_url, params: {}
    end

    # Http code
    assert_response :unprocessable_entity

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_not_empty json_response['errors']

    assert_equal ['param is missing or the value is empty or invalid: offer'], json_response['errors']['base']
  end

  test 'should not create with invlid params' do
    # Database changes
    assert_no_difference 'Offer.count' do
      post api_offer_index_url,
           params: { offer: { name: 'Te', price: -100.5, target_date: '1970-01-01', comment: '', request_id: -1,
                              printer_user_id: 1, color_id: -1, filament_id: -1, print_quality: 1000.22, invalid: 'invalid' } }
    end

    # Http code
    assert_response :unprocessable_entity

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_not_empty json_response['errors']

    assert_equal ['must exist', "can't be blank"], json_response['errors']['request']
    assert_equal ['must exist', "can't be blank"], json_response['errors']['color']
    assert_equal ['must exist', "can't be blank"], json_response['errors']['filament']
    assert_equal ['must be less than or equal to 2'], json_response['errors']['print_quality']
    assert_equal ['must be greater than or equal to 0'], json_response['errors']['price']
    assert_equal ['must be greater than today'], json_response['errors']['target_date']
  end

  test 'should not create offer if duplicated' do
    # Database changes
    assert_no_difference 'Offer.count' do
      post api_offer_index_url,
           params: { offer: { name: 'Test Offer', price: 1.5, target_date: '2026-01-01', comment: 'test comment',
                              request_id: @offer2.request_id, printer_user_id: @offer2.printer_user_id,
                              color_id: @offer2.color_id, filament_id: @offer2.filament_id, print_quality: 0.22 } }
    end

    # Http code
    assert_response :unprocessable_entity

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_not_empty json_response['errors']

    assert_equal ['This offer already exists'], json_response['errors']['request']
  end

  test 'should not create an offer on your request' do
    # Database changes
    assert_no_difference 'Offer.count' do
      post api_offer_index_url,
           params: { offer: { name: 'Test Offer', price: 1.5, target_date: '2026-01-01', comment: 'test comment',
                              request_id: offers(:ten).request_id,
                              printer_user_id: printer_users(:one).id,
                              color_id: @offer.color_id, filament_id: @offer.filament_id, print_quality: 0.22 } }
    end

    # Http code
    assert_response :unprocessable_entity

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_not_empty json_response['errors']

    assert_equal ['You cannot create an offer on your own request'], json_response['errors']['offer']
  end

  test 'should not create an offer if request is already accepted' do
    sign_out @user
    sign_in @other_user

    # Database changes
    assert_no_difference 'Offer.count' do
      post api_offer_index_url,
           params: { offer: { name: 'Test Offer', price: 1.5, target_date: '2026-01-01', comment: 'test comment',
                              request_id: @offer.request_id, printer_user_id: @offer.printer_user_id,
                              color_id: @offer2.color_id, filament_id: @offer2.filament_id, print_quality: 0.22 } }
    end

    # Http code
    assert_response :unprocessable_entity

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_not_empty json_response['errors']

    assert_equal ['Request already accepted an offer. Cannot create'], json_response['errors']['offer']
  end

  test 'should not create offer if not logged in' do
    sign_out @user

    # Database changes
    assert_no_difference 'Offer.count' do
      post api_offer_index_url,
           params: { offer: { name: 'Test Offer', price: 1.5, target_date: '2026-01-01', comment: 'test comment',
                              request_id: @offer.request_id, printer_user_id: @offer.printer_user_id,
                              color_id: @offer.color_id, filament_id: @offer.filament_id, print_quality: 0.22 } }
    end

    # Http code
    assert_response :unauthorized

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_not_empty json_response['errors']

    assert_equal ['Invalid login credentials'], json_response['errors']['connection']
  end

  test 'should not create offer with someone elses printer' do
    # Database changes
    assert_no_difference 'Offer.count' do
      post api_offer_index_url,
           params: { offer: { name: 'Test Offer', price: 1.5, target_date: '2026-01-01', comment: 'test comment',
                              request_id: @offer2.request_id, printer_user_id: @offer.printer_user_id,
                              color_id: @offer.color_id, filament_id: @offer.filament_id, print_quality: 0.22 } }
    end

    # Http code
    assert_response :unprocessable_entity

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content

    assert_not_empty json_response['errors']

    assert_equal ['You are not allowed to create an offer on this printer'], json_response['errors']['offer']
  end

  test 'should not create offer if user dont have printer' do
    sign_out @user
    sign_in @other_user2

    # Database changes
    assert_no_difference 'Offer.count' do
      post api_offer_index_url,
           params: { offer: { name: 'Test Offer', price: 1.5, target_date: '2026-01-01', comment: 'test comment',
                              request_id: @offer2.request_id,
                              color_id: @offer.color_id, filament_id: @offer.filament_id, print_quality: 0.22 } }
    end

    # Http code
    assert_response :unprocessable_entity

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content

    assert_not_empty json_response['errors']

    assert_equal ['You need to have a printer to create an offer'],
                 json_response['errors']['offer']
  end

  # SHOW

  test 'should show offer' do
    # Database changes
    assert_no_difference 'Offer.count' do
      get api_offer_url(@offer2)
    end

    # Http code
    assert_response :success

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_equal 2, json_response['offer']['id']
    assert_equal 2.5, json_response['offer']['price']
    assert_equal '2021-01-02', json_response['offer']['target_date']
    assert_equal 0.22, json_response['offer']['print_quality']
    assert_nil json_response['offer']['cancelled_at']
    assert_equal 1, json_response['offer']['printer_user']['id']
    assert_equal 1, json_response['offer']['printer_user']['user']['id']
    assert_equal 'James Bond', json_response['offer']['printer_user']['user']['username']
    assert_equal 1, json_response['offer']['printer_user']['printer']['id']
    assert_equal 'Bambulab', json_response['offer']['printer_user']['printer']['model']
    assert_equal 2, json_response['offer']['color']['id']
    assert_equal 'Red', json_response['offer']['color']['name']
    assert_equal 2, json_response['offer']['filament']['id']
    assert_equal 'ABS', json_response['offer']['filament']['name']
  end

  test 'should not show offer if not yours' do
    # Database changes
    assert_no_difference 'Offer.count' do
      get api_offer_url(@offer)
    end

    # Http code
    assert_response :not_found

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_not_empty json_response['errors']

    assert_equal ["Couldn't find Offer with 'id'=1 [WHERE `offers`.`printer_user_id` IN (SELECT `printer_users`.`id` FROM `printer_users` WHERE `printer_users`.`user_id` = ?)]"],
                 json_response['errors']['base']
  end

  # UPDATE

  test 'should update offer' do
    # Database changes
    assert_no_difference 'Offer.count' do
      patch api_offer_url(@offer2),
            params: { offer: { price: 1.5, target_date: '2026-01-01', print_quality: 0.22,
                               printer_user_id: @offer2.printer_user_id, color_id: @offer2.color_id,
                               filament_id: @offer2.filament_id } }
    end

    # Http code
    assert_response :success

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_equal 2, json_response['offer']['id']
    assert_equal 1.5, json_response['offer']['price']
    assert_equal '2026-01-01', json_response['offer']['target_date']
    assert_equal 0.22, json_response['offer']['print_quality']
    assert_nil json_response['offer']['cancelled_at']
    assert_equal 1, json_response['offer']['printer_user_id']
    assert_equal 2, json_response['offer']['color_id']
    assert_equal 2, json_response['offer']['filament_id']
    assert_empty json_response['errors']
  end

  test 'should not update offer with invalid params' do
    # Database changes
    assert_no_difference 'Offer.count' do
      patch api_offer_url(@offer2),
            params: { offer: { price: -100.5, target_date: '1970-01-01', print_quality: 1000.22,
                               printer_user_id: -1, color_id: -1, filament_id: -1 } }
    end

    # Http code
    assert_response :unprocessable_entity

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_not_empty json_response['errors']

    assert_equal ['must exist', "can't be blank"], json_response['errors']['printer_user']
    assert_equal ['must exist', "can't be blank"], json_response['errors']['color']
    assert_equal ['must exist', "can't be blank"], json_response['errors']['filament']
    assert_equal ['must be less than or equal to 2'], json_response['errors']['print_quality']
    assert_equal ['must be greater than or equal to 0'], json_response['errors']['price']
    assert_equal ['must be greater than today'], json_response['errors']['target_date']
  end

  test 'should not update offer if not yours' do
    sign_out @user
    sign_in @other_user

    # Database changes
    assert_no_difference 'Offer.count' do
      patch api_offer_url(@offer2),
            params: { offer: { price: 1.5, target_date: '2026-01-01', print_quality: 0.22,
                               printer_user_id: @offer2.printer_user_id, color_id: @offer2.color_id,
                               filament_id: @offer2.filament_id } }
    end

    # Http code
    assert_response :not_found

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_not_empty json_response['errors']

    assert_equal ["Couldn't find Offer with 'id'=2 [WHERE `offers`.`printer_user_id` IN (SELECT `printer_users`.`id` FROM `printer_users` WHERE `printer_users`.`user_id` = ?)]"],
                 json_response['errors']['base']
  end

  # DEST
  test 'should destroy offer' do
    # Database changes
    assert_difference 'Offer.count', -1 do
      delete api_offer_url(@offer2)
    end

    # Http code
    assert_response :success

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_equal 2, json_response['offer']['id']
    assert_equal 2, json_response['offer']['request_id']
    assert_equal 1, json_response['offer']['printer_user_id']
    assert_equal 2, json_response['offer']['color_id']
    assert_equal 2, json_response['offer']['filament_id']
    assert_equal 2.5, json_response['offer']['price']
    assert_equal '2021-01-02', json_response['offer']['target_date']
    assert_equal '2021-01-02T00:00:00.000Z', json_response['offer']['created_at']
    assert_equal '2021-01-02T00:00:00.000Z', json_response['offer']['updated_at']
    assert_equal 0.22, json_response['offer']['print_quality']
    assert_nil json_response['offer']['cancelled_at']
    assert_empty json_response['errors']

    assert_empty json_response['errors']
  end

  test 'should not destroy offer if already rejected' do
    offer = offers(:ten)

    # reject offer
    put reject_api_offer_url(offer)
    assert_response :success

    sign_in @user

    # Database changes
    # assert_no_difference 'Offer.count' do
    delete api_offer_url(offer)
    # end

    # Http code
    assert_response :unprocessable_entity

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_not_empty json_response['errors']

    assert_equal ['Offer already rejected. Cannot delete'], json_response['errors']['offer']
  end

  test 'should not destroy offer if accepted' do
    sign_out @user
    sign_in @other_user

    # Database changes
    assert_no_difference 'Offer.count' do
      delete api_offer_url(@other_offer)
    end

    # Http code
    assert_response :unprocessable_entity

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_not_empty json_response['errors']

    assert_equal ['Offer already accepted. Cannot delete'], json_response['errors']['offer']
  end

  test 'should not destroy offer if not yours' do
    sign_out @user
    sign_in @other_user

    # Database changes
    assert_no_difference 'Offer.count' do
      delete api_offer_url(@offer2)
    end

    # Http code
    assert_response :not_found

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_not_empty json_response['errors']

    assert_equal ["Couldn't find Offer with 'id'=2 [WHERE `offers`.`printer_user_id` IN (SELECT `printer_users`.`id` FROM `printer_users` WHERE `printer_users`.`user_id` = ?)]"],
                 json_response['errors']['base']
  end

  test 'should not destroy offer if doesnt exist' do
    # Database changes
    assert_no_difference 'Offer.count' do
      delete api_offer_url(9999)
    end

    # Http code
    assert_response :not_found

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_not_empty json_response['errors']

    assert_equal [
      "Couldn't find Offer with 'id'=9999 [WHERE `offers`.`printer_user_id` IN " \
      '(SELECT `printer_users`.`id` FROM `printer_users` WHERE `printer_users`.`user_id` = ?)]'
    ], json_response['errors']['base']
  end

  # CANCEL

  test 'should cancel offer' do
    sign_out @user
    sign_in @other_user

    # Database changes
    assert_no_difference 'Offer.count' do
      put reject_api_offer_url(@offer2)
    end

    # Http code
    assert_response :success

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_equal 2, json_response['offer']['id']
    assert_equal 2, json_response['offer']['request_id']
    assert_equal 1, json_response['offer']['printer_user_id']
    assert_equal 2, json_response['offer']['color_id']
    assert_equal 2, json_response['offer']['filament_id']
    assert_equal 2.5, json_response['offer']['price']
    assert_equal '2021-01-02', json_response['offer']['target_date']
  end

  test 'should not cancel offer if already rejected' do
    sign_in @other_user
    put reject_api_offer_url(@offer2)
    assert_response :success

    sign_in @other_user

    # Database changes
    assert_no_difference 'Offer.count' do
      put reject_api_offer_url(@offer2)
    end

    # Http code
    assert_response :unprocessable_entity

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_not_empty json_response['errors']
    assert_equal ['Offer already rejected'], json_response['errors']['offer']
  end

  test 'should not cancel offer if not yours' do
    # Database changes
    assert_no_difference 'Offer.count' do
      put reject_api_offer_url(offers(:nine))
    end

    # Http code
    assert_response :unprocessable_entity

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_not_empty json_response['errors']

    assert_equal ['You are not allowed to reject this offer'], json_response['errors']['offer']
  end

  test 'should not cancel offer if already accepted' do
    offer = offers(:one)
    order = Order.new(offer_id: offer.id)
    order.save

    # Database changes
    assert_no_difference 'Offer.count' do
      put reject_api_offer_url(offer)
    end

    # Http code
    assert_response :unprocessable_entity

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_not_empty json_response['errors']

    assert_equal ['Offer already accepted. Cannot reject'], json_response['errors']['offer']
  end

  test 'should not cancel offer if doesnt exist' do
    # Database changes
    assert_no_difference 'Offer.count' do
      put reject_api_offer_url(9999)
    end

    # Http code
    assert_response :not_found

    # Response format
    json_response = assert_nothing_raised { JSON.parse(response.body) }

    # response content
    assert_not_empty json_response['errors']

    assert_equal ["Couldn't find Offer with 'id'=9999"], json_response['errors']['base']
  end
end
