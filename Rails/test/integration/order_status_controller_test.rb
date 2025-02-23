require "test_helper"

class OrderStatusControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    
  end

  test "should get show as consummer" do
    sign_in users(:one)

    assert_difference('OrderStatus.count', 0) do
      get api_order_status_path(1), as: :json
    end

    assert_response :ok
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal 1, @parsed_response["order_status"]["id"]
    assert_equal "Accepted", @parsed_response["order_status"]["status_name"]
    assert_equal "Order status one", @parsed_response["order_status"]["comment"]
    assert_equal 1, @parsed_response["order_status"]["order_id"]
  end

  test "should get show as printer" do
    sign_in users(:two)

    assert_difference('OrderStatus.count', 0) do
      get api_order_status_path(1), as: :json
    end

    assert_response :ok
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal 1, @parsed_response["order_status"]["id"]
    assert_equal "Accepted", @parsed_response["order_status"]["status_name"]
    assert_equal "Order status one", @parsed_response["order_status"]["comment"]
    assert_equal 1, @parsed_response["order_status"]["order_id"]
  end



  test "should not find unknown order status" do
    sign_in users(:one)

    assert_difference('OrderStatus.count', 0) do
      get api_order_status_path(999), as: :json
    end

    assert_response :not_found
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Order Status not found"], @parsed_response["errors"]["order_status"]
  end

  test "should not return the order status of an order that the user does not possess" do
    sign_in users(:three)

    assert_difference('OrderStatus.count', 0) do
      get api_order_status_path(1), as: :json
    end

    assert_response :forbidden
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["You are not authorized to view this order status"], @parsed_response["errors"]["order_status"]
  end

  # CREATE

  test "create order not found" do
    sign_in users(:two)

    assert_difference('OrderStatus.count', 0) do
      post api_order_status_index_path, params: { order_id: 999, status_name: 'Printing', comment: "Order status one" }, as: :json
    end

    assert_response :not_found
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Order not found"], @parsed_response["errors"]["order"]
  end

  test "should not create -> invalid status_name" do
    sign_in users(:two)

    assert_difference('OrderStatus.count', 0) do
      post api_order_status_index_path, params: { order_id: 1, status_name: 'InvalidStatus', comment: "Order status one" }, as: :json
    end

    assert_response :bad_request
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    p @parsed_response
  end

  test "should not create -> invalid comment" do
    sign_in users(:two)

    assert_difference('OrderStatus.count', 0) do
      post api_order_status_index_path, params: { order_id: 1, status_name: 'Printing', comment: "allo" }, as: :json
    end

    assert_response :bad_request
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["is too short (minimum is 5 characters)"], @parsed_response["errors"]["comment"]
  end

  test "should not create -> not signed in" do
    assert_difference('OrderStatus.count', 0) do
      post api_order_status_index_path, params: { order_id: 1, status_name: 'Printing', comment: "Order status one" }, as: :json
    end

    assert_response :unauthorized
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Invalid login credentials"], @parsed_response["errors"]["connection"]
  end

  test "should not create -> no status_name" do
    sign_in users(:two)

    assert_difference('OrderStatus.count', 0) do
      post api_order_status_index_path, params: { order_id: 2, comment: "Order status one" }, as: :json
    end

    assert_response :bad_request
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Invalid transition from Printing to Accepted"], @parsed_response["errors"]["status_name"]
  end

  test "creation after Cancelled (printer)" do
    ["Accepted", "Printing", "Printed", "Shipped", "Cancelled", "Arrived"].each do |status|
      shouldNotCreateOrderStatus("Cancelled", status, users(:two), 6)
    end
  end

  test "creation after Cancelled (consumer)" do
    ["Accepted", "Printing", "Printed", "Shipped", "Cancelled", "Arrived"].each do |status|
      shouldNotCreateOrderStatus("Cancelled", status, users(:one), 6)
    end
  end

  test "creation after Arrived (printer)" do
    ["Accepted", "Printing", "Printed", "Shipped", "Cancelled", "Arrived"].each do |status|
      shouldNotCreateOrderStatus("Arrived", status, users(:two), 5)
    end
  end

  test "creation after Arrived (consumer)" do
    ["Accepted", "Printing", "Printed", "Shipped", "Cancelled", "Arrived"].each do |status|
      shouldNotCreateOrderStatus("Arrived", status, users(:one), 5)
    end
  end

  test "creation after Shipped (printer)" do
    ["Accepted", "Printing", "Printed", "Shipped", "Cancelled", "Arrived"].each do |status|
      shouldNotCreateOrderStatus("Shipped", status, users(:two), 4)
    end
  end

  test "creation after Shipped (consumer)" do
    ["Accepted", "Printing", "Printed", "Shipped", "Cancelled"].each do |status|
      shouldNotCreateOrderStatus("Shipped", status, users(:one), 4)
    end
    shouldCreateOrderStatus("Arrived", users(:one), 4)
  end

  test "creation after Printed (printer)" do
    ["Accepted", "Printing", "Arrived"].each do |status|
      shouldNotCreateOrderStatus("Printed", status, users(:two), 3)
    end
    ["Printed", "Shipped"].each do |status|
      shouldCreateOrderStatus(status, users(:two), 3)
    end
  end

  test "creation after Printed (consumer)" do
    ["Accepted", "Printing", "Printed", "Shipped", "Cancelled", "Arrived"].each do |status|
      shouldNotCreateOrderStatus("Printed", status, users(:one), 3)
    end
  end

  test "creation after Printing (printer)" do
    ["Accepted", "Shipped", "Arrived"].each do |status|
      shouldNotCreateOrderStatus("Printing", status, users(:two), 2)
    end
    ["Printing", "Printed"].each do |status|
      shouldCreateOrderStatus(status, users(:two), 2)
    end
  end

  test "creation after Printing (consumer)" do
    ["Accepted", "Printing", "Printed", "Shipped", "Cancelled", "Arrived"].each do |status|
      shouldNotCreateOrderStatus("Printing", status, users(:one), 2)
    end
  end

  test "creation after Accepted (printer)" do
    ["Printed", "Shipped", "Arrived"].each do |status|
      shouldNotCreateOrderStatus("Accepted", status, users(:two), 1)
    end
    ["Accepted", "Printing"].each do |status|
      shouldCreateOrderStatus(status, users(:two), 1)
    end
  end

  test "creation after Accepted (consumer)" do
    ["Accepted", "Printing", "Printed", "Shipped", "Arrived"].each do |status|
      shouldNotCreateOrderStatus("Accepted", status, users(:one), 1)
    end
  end

  test "should create Cancelled(printer)" do
    shouldCreateOrderStatus("Cancelled", users(:two), 1)
    shouldCreateOrderStatus("Cancelled", users(:two), 2)
    shouldCreateOrderStatus("Cancelled", users(:two), 3)
  end

  test "should create Cancelled(consumer)" do
    shouldCreateOrderStatus("Cancelled", users(:one), 1)
  end

  # UPDATE
  
  test "should not update -> not signed in" do
    assert_difference('OrderStatus.count', 0) do
      patch api_order_status_path(1), params: { status_name: 'Printing', comment: "Order status one" }, as: :json
    end

    assert_response :unauthorized
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Invalid login credentials"], @parsed_response["errors"]["connection"]
  end

  test "should not update -> not found" do
    sign_in users(:two)

    assert_difference('OrderStatus.count', 0) do
      patch api_order_status_path(999), params: { status_name: 'Printing', comment: "Order status one" }, as: :json
    end

    assert_response :not_found
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Order status not found"], @parsed_response["errors"]["order_status"]
  end

  test "should not update -> not owner" do
    sign_in users(:one)
    assert_difference('OrderStatus.count', 0) do
      patch api_order_status_path(1), params: { status_name: 'Printing', comment: "Order Status one" }, as: :json
    end

    assert_response :forbidden
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["You are not authorized to update this order status"], @parsed_response["errors"]["order_status"]
  end

  test "should not update -> invalid comment" do
    sign_in users(:two)
    assert_difference('OrderStatus.count', 0) do
      patch api_order_status_path(1), params: { status_name: 'Printing', comment: "allo" }, as: :json
    end

    assert_response :bad_request
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["is too short (minimum is 5 characters)"], @parsed_response["errors"]["comment"]
  end

  
  test "can update while Accepted" do
    sign_in users(:two)
    assert_difference('OrderStatus.count', 0) do
      patch api_order_status_path(1), params: { comment: "this is changed" }, as: :json
    end

    assert_response :ok
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    createdOS =  @parsed_response["order_status"]
    assert_equal 1, createdOS["order_id"]
    assert_equal "this is changed", createdOS["comment"]
    assert_equal "Accepted", createdOS["status_name"]
    assert_empty @parsed_response["errors"]
  end

  test "can update while Printing" do
    sign_in users(:two)
    assert_difference('OrderStatus.count', 0) do
      patch api_order_status_path(3), params: { comment: "this is changed" }, as: :json
    end

    assert_response :ok
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    createdOS =  @parsed_response["order_status"]
    assert_equal 2, createdOS["order_id"]
    assert_equal "this is changed", createdOS["comment"]
    assert_equal "Printing", createdOS["status_name"]
    assert_empty @parsed_response["errors"]
  end

  test "can update while Printed" do
    sign_in users(:two)
    assert_difference('OrderStatus.count', 0) do
      patch api_order_status_path(6), params: { comment: "this is changed" }, as: :json
    end

    assert_response :ok
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    createdOS =  @parsed_response["order_status"]
    assert_equal 3, createdOS["order_id"]
    assert_equal "this is changed", createdOS["comment"]
    assert_equal "Printed", createdOS["status_name"]
    assert_empty @parsed_response["errors"]
  end

  test "can't update while Shipped" do
    sign_in users(:two)
    assert_difference('OrderStatus.count', 0) do
      patch api_order_status_path(10), params: { comment: "this is changed" }, as: :json
    end

    assert_response :bad_request
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Cannot change status of a frozen order"], @parsed_response["errors"]["order_status"]
  end

  test "can't update while Arrived" do
    sign_in users(:two)
    assert_difference('OrderStatus.count', 0) do
      patch api_order_status_path(15), params: { comment: "this is changed" }, as: :json
    end

    assert_response :bad_request
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Cannot change status of a frozen order"], @parsed_response["errors"]["order_status"]
  end

  test "can't update while Cancelled" do
    sign_in users(:two)
    assert_difference('OrderStatus.count', 0) do
      patch api_order_status_path(17), params: { comment: "this is changed" }, as: :json
    end

    assert_response :bad_request
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Cannot change status of a frozen order"], @parsed_response["errors"]["order_status"]
  end

  # DESTROY
  
  test "should not destroy -> not signed in" do
    assert_difference('OrderStatus.count', 0) do
      delete api_order_status_path(1), as: :json
    end

    assert_response :unauthorized
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Invalid login credentials"], @parsed_response["errors"]["connection"]
  end

  test "should not destroy -> not found" do
    sign_in users(:two)

    assert_difference('OrderStatus.count', 0) do
      delete api_order_status_path(999), as: :json
    end

    assert_response :not_found
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["Order status not found"], @parsed_response["errors"]["order_status"]
  end

  test "should not destroy -> not owner" do
    sign_in users(:one)
    assert_difference('OrderStatus.count', 0) do
      delete api_order_status_path(1), as: :json
    end

    assert_response :forbidden
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal ["You are not authorized to delete this order status"], @parsed_response["errors"]["order_status"]
  end

  
  test "destroy while Accepted" do
    shouldNotDestroyOrderStatus(users(:two), 1)
  end

  test "destroy while Printing" do
    shouldNotDestroyOrderStatus(users(:two), 2)
    shouldDestroyOrderStatus(users(:two), order_status(:three))
  end

  test "destroy while Printed" do
    shouldNotDestroyOrderStatus(users(:two), 4)
    shouldDestroyOrderStatus(users(:two), order_status(:five))
    shouldDestroyOrderStatus(users(:two), order_status(:six))
  end

  test "destroy while Shipped" do
    shouldNotDestroyOrderStatus(users(:two), 7)
    shouldNotDestroyOrderStatus(users(:two), 8)
    shouldNotDestroyOrderStatus(users(:two), 9)
    shouldNotDestroyOrderStatus(users(:two), 10)
  end

  test "destroy while Arrived" do
    shouldNotDestroyOrderStatus(users(:two), 11)
    shouldNotDestroyOrderStatus(users(:two), 12)
    shouldNotDestroyOrderStatus(users(:two), 13)
    shouldNotDestroyOrderStatus(users(:two), 14)
    shouldNotDestroyOrderStatus(users(:two), 15)
  end

  test "destroy while Cancelled" do
    shouldNotDestroyOrderStatus(users(:two), 16)
    shouldNotDestroyOrderStatus(users(:two), 17)
  end

  private

  def shouldCreateOrderStatus(to, as, order_id)
    sign_in as

    assert_difference('OrderStatus.count', 1) do
      post api_order_status_index_path, params: { order_id: order_id, status_name: to, comment: "Order status one" }, as: :json
    end

    assert_response :created
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    created_order = @parsed_response["order_status"]
    assert_equal order_id, created_order["order_id"]
    assert_equal to, created_order["status_name"]
    assert_equal "Order status one", created_order["comment"]
    assert_empty @parsed_response["errors"]
  end

  def shouldNotCreateOrderStatus(from, to, as, order_id)
    sign_in as

    assert_difference('OrderStatus.count', 0) do
      post api_order_status_index_path, params: { order_id: order_id, status_name: to, comment: "Order status one" }, as: :json
    end

    assert_response :bad_request
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    if !@parsed_response["errors"]["order_status"].nil?
      assert_equal ["Invalid transition from #{from} to #{to}"], @parsed_response["errors"]["order_status"]
    end
    if !@parsed_response["errors"]["status_name"].nil?
      assert_equal ["Invalid transition from #{from} to #{to}"], @parsed_response["errors"]["status_name"]
    end
  end

  def shouldDestroyOrderStatus(as, order_status)
    sign_in as

    assert_difference('OrderStatus.count', -1) do
      delete api_order_status_path(order_status.id), as: :json
    end

    assert_response :ok
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_equal order_status.id, @parsed_response["order_status"]["id"]
    assert_equal order_status.order_id, @parsed_response["order_status"]["order_id"]
    assert_equal order_status.status_name, @parsed_response["order_status"]["status_name"]
    assert_equal order_status.comment, @parsed_response["order_status"]["comment"]
    assert_empty @parsed_response["errors"]
  end

  def shouldNotDestroyOrderStatus(as, order_status_id)
    sign_in as

    assert_difference('OrderStatus.count', 0) do
      delete api_order_status_path(order_status_id), as: :json
    end

    assert_response :bad_request
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_includes ["Cannot delete the status", "Cannot change status of a frozen order"], @parsed_response["errors"]["order_status"][0]
  end
end