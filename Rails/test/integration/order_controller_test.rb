require "test_helper"

class OrderControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    
  end

  test "should get index" do
    sign_in users(:one)

    assert_difference('Order.count', 0) do
      get api_order_index_path
    end

    assert_response :success
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal 6, @parsed_response["orders"].length
    tested_order = @parsed_response["orders"][0]
    testOrder(tested_order)
  end

  test "should get show" do
    sign_in users(:one)

    assert_difference('Order.count', 0) do
      get api_order_path(1)
    end
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    testOrder(@parsed_response["order"])
  end

  private
  def testOrder(tested_order)
    assert_nil tested_order["offer_id"]

    assert_equal 1, tested_order["offer"]["id"]
    assert_equal "High", tested_order["offer"]["print_quality"]
    assert_equal 1.5, tested_order["offer"]["price"]

    assert_equal 2, tested_order["offer"]["printer_user"]["id"]
    assert_equal "2025-02-14", tested_order["offer"]["printer_user"]["acquired_date"]
    assert_nil tested_order["offer"]["printer_user"]["printer_id"]
    assert_nil tested_order["offer"]["printer_user"]["user_id"]

    assert_equal 2, tested_order["offer"]["printer_user"]["user"]["id"]
    assert_equal "John Doe", tested_order["offer"]["printer_user"]["user"]["username"]
    assert_nil tested_order["offer"]["printer_user"]["user"]["created_at"]
    assert_nil tested_order["offer"]["printer_user"]["user"]["updated_at"]
    assert_nil tested_order["offer"]["printer_user"]["user"]["is_admin"]
    assert_nil tested_order["offer"]["printer_user"]["user"]["profile_picture_url"]

    assert_equal 2, tested_order["offer"]["printer_user"]["user"]["country"]["id"]
    assert_equal "USA", tested_order["offer"]["printer_user"]["user"]["country"]["name"]

    assert_equal 2, tested_order["offer"]["printer_user"]["printer"]["id"]
    assert_equal "MyString", tested_order["offer"]["printer_user"]["printer"]["model"]

    assert_equal 1, tested_order["offer"]["request"]["id"]
    assert_equal 100, tested_order["offer"]["request"]["budget"]
    assert_equal "2021-12-31", tested_order["offer"]["request"]["target_date"]
    assert_equal "Test Comments", tested_order["offer"]["request"]["comment"]
    assert_nil tested_order["offer"]["request"]["created_at"]
    assert_nil tested_order["offer"]["request"]["updated_at"]
    assert_nil tested_order["offer"]["request"]["user_id"]

    assert_equal 1, tested_order["offer"]["request"]["user"]["id"]
    assert_equal "James Bond", tested_order["offer"]["request"]["user"]["username"]
    assert_nil tested_order["offer"]["request"]["user"]["created_at"]
    assert_nil tested_order["offer"]["request"]["user"]["updated_at"]
    assert_nil tested_order["offer"]["request"]["user"]["is_admin"]
    assert_nil tested_order["offer"]["request"]["user"]["profile_picture_url"]

    assert_equal 1, tested_order["offer"]["request"]["user"]["country"]["id"]
    assert_equal "Canada", tested_order["offer"]["request"]["user"]["country"]["name"]

    assert_equal 1, tested_order["offer"]["color"]["id"]
    assert_equal "Blue", tested_order["offer"]["color"]["name"]

    assert_equal 1, tested_order["offer"]["filament"]["id"]
    assert_equal "PLA", tested_order["offer"]["filament"]["name"]

    #TODO : Add reviews

    assert_equal 1, tested_order["order_status"].length
    tested_order_status = tested_order["order_status"][0]
    assert_nil tested_order_status["order_id"]
    assert_equal 1, tested_order_status["id"]
    assert_equal "Accepted", tested_order_status["status_name"]
    assert_equal "Order status one", tested_order_status["comment"]
    assert_equal "2023-09-30T20:00:00.000-04:00", tested_order_status["created_at"]
    assert_equal "2023-09-30T20:00:00.000-04:00", tested_order_status["updated_at"]
  end

end