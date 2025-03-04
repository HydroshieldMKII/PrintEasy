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

    expected_response = [
      { 'id' => @printer_user_one.id, 'acquired_date' => @printer_user_one.acquired_date.to_s,
        "last_review_image" => nil, 'printer' => { 'id' => @printer_user_one.printer.id, 'model' => @printer_user_one.printer.model } }
    ]

    assert_equal expected_response, json_response
  end

  test 'should create printer_user' do
    assert_difference 'PrinterUser.count', 1 do
      post api_printer_user_index_path, params: { printer_user: { printer_id: printers(:two).id, acquired_date: Time.now - 10.days } }
    end

    assert_response :success

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal printers(:two).id, json_response['printer']['id']
    assert_equal 10.days.ago.to_date, json_response['acquired_date'].to_date
  end

  test "should update printer_user" do
    patch api_printer_user_path(@printer_user_one), params: { printer_user: { acquired_date: Time.now - 5.days } }

    assert_response :success

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 5.days.ago.to_date, json_response['acquired_date'].to_date
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

  test "should not destroy printer_user" do
    assert_difference 'PrinterUser.count', 0 do
      delete api_printer_user_path(@printer_user_two)
    end

    assert_response :not_found

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal ["Couldn't find PrinterUser with 'id'=2 [WHERE `printer_users`.`user_id` = ?]"], json_response['errors']['base']
  end
end
