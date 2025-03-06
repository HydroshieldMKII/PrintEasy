# frozen_string_literal: true

require 'test_helper'

class PrinterUserControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @printer_user_one = printer_users(:one)
    @printer_user_two = printer_users(:two)

    sign_in @user
  end

  test 'should get index' do
    assert_difference 'PrinterUser.count', 0 do
      get api_printer_user_index_path, as: :json
    end
    assert_response :success
    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 1, json_response['printer_users'].length
    printer_user = json_response['printer_users'][0]
    assert_equal 1, printer_user['id']
    assert_equal '2025-02-14', printer_user['acquired_date']
    assert_nil printer_user['last_review_image']
    assert_nil printer_user['last_used']
    assert_equal false, printer_user['can_update']
    assert_equal 1, printer_user['printer']['id']
    assert_equal 'Bambulab', printer_user['printer']['model']
    assert_equal 1, printer_user['user']['id']
    assert_equal 'James Bond', printer_user['user']['username']
    assert_equal 1, printer_user['user']['country_id']
    assert_equal 'Canada', printer_user['user']['country']['name']
  end

  test 'should create printer_user' do
    assert_difference 'PrinterUser.count', 1 do
      post api_printer_user_index_path, params: { printer_user: { printer_id: printers(:two).id, acquired_date: 10.days.ago } }
    end

    assert_response :success

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal printers(:two).id, json_response['printer_user']['printer']['id']
    assert_equal 10.days.ago.to_date, json_response['printer_user']['acquired_date'].to_date
  end

  test 'should update printer_user' do
    patch api_printer_user_path(@printer_user_one), params: { printer_user: { acquired_date: 5.days.ago } }

    assert_response :success

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end
    
    assert_equal 5.days.ago.to_date, json_response["printer_user"]['acquired_date'].to_date
  end

  test 'should destroy printer_user' do
    assert_difference 'PrinterUser.count', -1 do
      delete api_printer_user_path(@printer_user_one)
    end

    assert_response :success

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal @printer_user_one.id, json_response['printer_user']['id']
  end

  test 'should not destroy printer_user if not owner' do
    assert_difference 'PrinterUser.count', 0 do
      delete api_printer_user_path(@printer_user_two)
    end

    assert_response :not_found

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal ["Couldn't find PrinterUser with 'id'=2 [WHERE `printer_users`.`user_id` = ?]"], json_response['errors']['base']
  end

  test 'should not create printer_user with invalid printer_id' do
    assert_difference 'PrinterUser.count', 0 do
      post api_printer_user_index_path, params: { printer_user: { printer_id: 0, acquired_date: Time.now - 10.days } }
    end

    assert_response :unprocessable_entity

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal ['must exist'], json_response['errors']['printer']
  end

  test 'should not create printer_user with invalid acquired_date' do
    assert_difference 'PrinterUser.count', 0 do
      post api_printer_user_index_path, params: { printer_user: { printer_id: printers(:two).id, acquired_date: nil } }
    end

    assert_response :unprocessable_entity

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal ["can't be blank"], json_response['errors']['acquired_date']
  end

  test 'should not create printer_user with acquired_date in the future' do
    assert_difference 'PrinterUser.count', 0 do
      post api_printer_user_index_path,
           params: { printer_user: { printer_id: printers(:two).id, acquired_date: Time.now + 10.days } }
    end

    assert_response :unprocessable_entity

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal ['cannot be in the future'], json_response['errors']['acquired_date']
  end

  test 'should not update printer_user with invalid printer_id' do
    assert_difference 'PrinterUser.count', 0 do
      patch api_printer_user_path(@printer_user_one),
            params: { printer_user: { printer_id: 0, acquired_date: Time.now - 10.days } }
    end

    assert_response :unprocessable_entity

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal ['must exist'], json_response['errors']['printer']
  end

  test 'should not update printer_user with future acquired_date' do
    assert_difference 'PrinterUser.count', 0 do
      patch api_printer_user_path(@printer_user_one), params: { printer_user: { acquired_date: Time.now + 10.days } }
    end

    assert_response :unprocessable_entity

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal ['cannot be in the future'], json_response['errors']['acquired_date']
  end

  test 'should not update printer_user with invalid acquired_date' do
    assert_difference 'PrinterUser.count', 0 do
      patch api_printer_user_path(@printer_user_one), params: { printer_user: { acquired_date: nil } }
    end

    assert_response :unprocessable_entity

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal ["can't be blank"], json_response['errors']['acquired_date']
  end

  test 'should not update printer_user with invalid id' do
    assert_difference 'PrinterUser.count', 0 do
      patch api_printer_user_path(0), params: { printer_user: { acquired_date: Time.now - 10.days } }
    end

    assert_response :not_found

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal ["Couldn't find PrinterUser with 'id'=0 [WHERE `printer_users`.`user_id` = ?]"], json_response['errors']['base']
  end

  test 'should not destroy printer_user with invalid id' do
    assert_difference 'PrinterUser.count', 0 do
      delete api_printer_user_path(0)
    end

    assert_response :not_found

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal ["Couldn't find PrinterUser with 'id'=0 [WHERE `printer_users`.`user_id` = ?]"], json_response['errors']['base']
  end

  test 'should not destroy printer_user if not signed in' do
    sign_out @user

    assert_difference 'PrinterUser.count', 0 do
      delete api_printer_user_path(@printer_user_one)
    end

    assert_response :unauthorized

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal ['Invalid login credentials'], json_response['errors']['connection']
  end

  test 'should not create printer_user if not signed in' do
    sign_out @user

    assert_difference 'PrinterUser.count', 0 do
      post api_printer_user_index_path, params: { printer_user: { printer_id: printers(:two).id, acquired_date: 10.days.ago } }
    end

    assert_response :unauthorized

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal ['Invalid login credentials'], json_response['errors']['connection']
  end

  test 'should not update printer_user if not signed in' do
    sign_out @user

    assert_difference 'PrinterUser.count', 0 do
      patch api_printer_user_path(@printer_user_one), params: { printer_user: { acquired_date: 5.days.ago } }
    end

    assert_response :unauthorized

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal ['Invalid login credentials'], json_response['errors']['connection']
  end

  test 'should not get index if not signed in' do
    sign_out @user

    assert_difference 'PrinterUser.count', 0 do
      get api_printer_user_index_path, as: :json
    end

    assert_response :unauthorized

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal ['Invalid login credentials'], json_response['errors']['connection']
  end

  test 'should not destroy printer_user if it has offers' do
    sign_out @user
    sign_in users(:two)

    assert_difference 'PrinterUser.count', 0 do
      delete api_printer_user_path(@printer_user_two)
    end

    assert_response :unprocessable_entity

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal ['Cannot update printer user with orders'], json_response['errors']['base']
  end

  test 'should not update printer_user if it has offers' do
    sign_out @user
    sign_in users(:two)

    assert_difference 'PrinterUser.count', 0 do
      patch api_printer_user_path(@printer_user_two), params: { printer_user: { acquired_date: 5.days.ago } }
    end

    assert_response :unprocessable_entity

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal ['Cannot update printer user with orders'], json_response['errors']['base']
  end
end
