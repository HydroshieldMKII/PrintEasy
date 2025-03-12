# frozen_string_literal: true

require 'test_helper'

class OrderReportControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:two)
  end

  test 'should get report' do
    assert_difference('Order.count', 0) do
      get report_api_order_index_path, as: :json
    end

    assert_response :success
    assert_nothing_raised do
      @parsed_response = JSON.parse(@response.body)
    end
    assert_empty @parsed_response['errors']
    assert_equal 1, @parsed_response['printers'].length

    assert_equal printers(:two).model, @parsed_response['printers'][0]['printer_model']
    assert_equal 1, @parsed_response['printers'][0]['completed_orders']
    assert_equal 2, @parsed_response['printers'][0]['cancelled_orders']
    assert_equal 4, @parsed_response['printers'][0]['in_progress_orders']
    assert_nil @parsed_response['printers'][0]['average_rating']
    assert_equal '27:25:42', @parsed_response['printers'][0]['average_time_to_complete']
    assert_equal 1.5, @parsed_response['printers'][0]['money_earned']
  end

  test 'should get report with sort' do
    assert_difference('Order.count', 0) do
      get report_api_order_index_path(sort: 'time-asc'), as: :json
    end

    assert_response :success
    assert_nothing_raised do
      @parsed_response = JSON.parse(@response.body)
    end
    assert_empty @parsed_response['errors']
    assert_equal 1, @parsed_response['printers'].length

    assert_equal printers(:two).model, @parsed_response['printers'][0]['printer_model']
    assert_equal 1, @parsed_response['printers'][0]['completed_orders']
    assert_equal 2, @parsed_response['printers'][0]['cancelled_orders']
    assert_equal 4, @parsed_response['printers'][0]['in_progress_orders']
    assert_nil @parsed_response['printers'][0]['average_rating']
    assert_equal '27:25:42', @parsed_response['printers'][0]['average_time_to_complete']
    assert_equal 1.5, @parsed_response['printers'][0]['money_earned']
  end

  test 'should get report with start date' do
    assert_difference('Order.count', 0) do
      get report_api_order_index_path(start_date: '2023-10-03'), as: :json
    end

    assert_response :success
    assert_nothing_raised do
      @parsed_response = JSON.parse(@response.body)
    end

    assert_empty @parsed_response['errors']
    assert_equal 1, @parsed_response['printers'].length

    assert_equal printers(:two).model, @parsed_response['printers'][0]['printer_model']
    assert_equal 1, @parsed_response['printers'][0]['completed_orders']
    assert_equal 1, @parsed_response['printers'][0]['cancelled_orders']
    assert_equal 0, @parsed_response['printers'][0]['in_progress_orders']
    assert_nil @parsed_response['printers'][0]['average_rating']
    assert_equal '48:00:00', @parsed_response['printers'][0]['average_time_to_complete']
    assert_equal 1.5, @parsed_response['printers'][0]['money_earned']
  end

  test 'should get report with end date' do
    assert_difference('Order.count', 0) do
      get report_api_order_index_path(end_date: '2023-10-03'), as: :json
    end

    assert_response :success
    assert_nothing_raised do
      @parsed_response = JSON.parse(@response.body)
    end
    assert_empty @parsed_response['errors']
    assert_equal 1, @parsed_response['printers'].length

    assert_equal printers(:two).model, @parsed_response['printers'][0]['printer_model']
    assert_equal 1, @parsed_response['printers'][0]['completed_orders']
    assert_equal 2, @parsed_response['printers'][0]['cancelled_orders']
    assert_equal 4, @parsed_response['printers'][0]['in_progress_orders']
    assert_nil @parsed_response['printers'][0]['average_rating']
    assert_equal '27:25:42', @parsed_response['printers'][0]['average_time_to_complete']
    assert_equal 1.5, @parsed_response['printers'][0]['money_earned']
  end
end
