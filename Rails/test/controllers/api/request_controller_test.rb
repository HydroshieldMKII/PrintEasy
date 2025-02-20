require 'test_helper'

class Api::RequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @request = requests(:chess_set)
    @preset = preset_requests(:preset_one)

    sign_in @user
  end

  ### INDEX ACTION ###
  test "should return all requests for 'all' type" do
    get api_requests_url, params: { type: 'all' }, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response['request'].is_a?(Array)
  end

  test "should return user's own requests for 'my' type" do
    get api_requests_url, params: { type: 'my' }, as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert json_response['request'].all? { |r| r['user']['id'] == @user.id }
  end

  ### SHOW ACTION ###
  test "should show a specific request" do
    get api_request_url(@request), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @request.id, json_response['request']['id']
  end

  test "should return error for nonexistent request" do
    get api_request_url(id: 9999), as: :json
    assert_response :not_found
  end

  ### CREATE ACTION ###
  test "should create request with valid parameters" do
    assert_difference('Request.count', 1) do
      post api_requests_url, params: {
        request: {
          name: "New Request",
          comment: "This is a new request",
          budget: 100,
          target_date: 5.days.from_now.to_date,
          stl_file: fixture_file_upload('files/test_file.stl', 'application/octet-stream'),
          preset_requests_attributes: [
            { color_id: 1, filament_id: 1, printer_id: 1, print_quality: 0.1 }
          ]
        }
      }, as: :json
    end

    assert_response :created
  end

  test "should not create request with invalid data" do
    assert_no_difference('Request.count') do
      post api_requests_url, params: {
        request: { name: "", budget: -10, target_date: "2020-01-01" }
      }, as: :json
    end

    assert_response :unprocessable_entity
  end

  ### UPDATE ACTION ###
  test "should update request with valid data" do
    patch api_request_url(@request), params: {
      request: { name: "Updated Request", budget: 150 }
    }, as: :json

    assert_response :success
    @request.reload
    assert_equal "Updated Request", @request.name
  end

  test "should not allow user to update another user's request" do
    sign_in @other_user

    patch api_request_url(@request), params: {
      request: { name: "Hacked Update" }
    }, as: :json

    assert_response :forbidden
  end

  test "should not update request with invalid data" do
    patch api_request_url(@request), params: {
      request: { name: "" }
    }, as: :json

    assert_response :unprocessable_entity
  end

  ### DELETE ACTION ###
  test "should delete own request" do
    assert_difference('Request.count', -1) do
      delete api_request_url(@request), as: :json
    end

    assert_response :success
  end

  test "should not allow user to delete another user's request" do
    sign_in @other_user

    assert_no_difference('Request.count') do
      delete api_request_url(@request), as: :json
    end

    assert_response :forbidden
  end
end
