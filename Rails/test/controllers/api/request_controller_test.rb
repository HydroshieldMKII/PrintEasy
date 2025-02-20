require 'test_helper'

class Api::RequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @user_request = requests(:request_one)
    @preset = preset_requests(:preset_request_one)

    sign_in @user
  end

  ### INDEX ACTION ###
  test "should return all requests for 'all' type" do
    get api_request_index_path, params: { type: 'all' }
    assert_response :success
  
    assert_nothing_raised do
      json_response = JSON.parse(response.body)
      assert json_response['request'].is_a?(Array)

      all_requests_not_mine = Request.where.not(user_id: @user.id)
      assert_equal all_requests_not_mine.count, json_response['request'].length

      # {"request":[{"id":6,"name":"User Request 1","budget":15.0,"comment":"This is request number 1 from user.","target_date":"2025-03-02","stl_file_url":"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6NywicHVyIjoiYmxvYl9pZCJ9fQ==--fc1ba8557eb636122cc8ed65e8d6c5b164305e33/RUBY13.stl","preset_requests":[{"id":10,"print_quality":0.08,"color":{"id":1,"name":"Red"},"filament":{"id":1,"name":"PETG"},"printer":{"id":1,"model":"Bambulab"}},{"id":11,"print_quality":0.12,"color":{"id":2,"name":"Blue"},"filament":{"id":2,"name":"TPU"},"printer":{"id":2,"model":"Anycubic"}},{"id":12,"print_quality":0.16,"color":{"id":3,"name":"Green"},"filament":{"id":3,"name":"Nylon"},"printer":{"id":3,"model":"Artillery"}}],"user":{"id":2,"username":"aaa","country":{"name":"Canada"}}},{"id":7,"name":"User Request 2","budget":30.0,"comment":"This is request number 2 from user.","target_date":"2025-03-03","stl_file_url":"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6OCwicHVyIjoiYmxvYl9pZCJ9fQ==--1d63d35dee7862b7b74d2b0b1b2897c89c95351c/RUBY13.stl","preset_requests":[],"user":{"id":2,"username":"aaa","country":{"name":"Canada"}}},{"id":8,"name":"User Request 3","budget":45.0,"comment":"This is request number 3 from user.","target_date":"2025-03-04","stl_file_url":"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6OSwicHVyIjoiYmxvYl9pZCJ9fQ==--e50f2dd8a98053b8a8d7af299ee7a977caefbe8d/RUBY13.stl","preset_requests":[{"id":13,"print_quality":0.08,"color":{"id":1,"name":"Red"},"filament":{"id":1,"name":"PETG"},"printer":{"id":1,"model":"Bambulab"}},{"id":14,"print_quality":0.12,"color":{"id":2,"name":"Blue"},"filament":{"id":2,"name":"TPU"},"printer":{"id":2,"model":"Anycubic"}},{"id":15,"print_quality":0.16,"color":{"id":3,"name":"Green"},"filament":{"id":3,"name":"Nylon"},"printer":{"id":3,"model":"Artillery"}}],"user":{"id":2,"username":"aaa","country":{"name":"Canada"}}},{"id":9,"name":"User Request 4","budget":60.0,"comment":"This is request number 4 from user.","target_date":"2025-03-05","stl_file_url":"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MTAsInB1ciI6ImJsb2JfaWQifX0=--74bdc50f681e4573fa8e58048fa36973b463ee45/RUBY13.stl","preset_requests":[{"id":16,"print_quality":0.08,"color":{"id":1,"name":"Red"},"filament":{"id":1,"name":"PETG"},"printer":{"id":1,"model":"Bambulab"}},{"id":17,"print_quality":0.12,"color":{"id":2,"name":"Blue"},"filament":{"id":2,"name":"TPU"},"printer":{"id":2,"model":"Anycubic"}},{"id":18,"print_quality":0.16,"color":{"id":3,"name":"Green"},"filament":{"id":3,"name":"Nylon"},"printer":{"id":3,"model":"Artillery"}}],"user":{"id":2,"username":"aaa","country":{"name":"Canada"}}},{"id":10,"name":"User Request 5","budget":75.0,"comment":"This is request number 5 from user.","target_date":"2025-03-06","stl_file_url":"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MTEsInB1ciI6ImJsb2JfaWQifX0=--397a37b94e71a3d19d7772120f47d4e3361b398b/RUBY13.stl","preset_requests":[{"id":19,"print_quality":0.08,"color":{"id":1,"name":"Red"},"filament":{"id":1,"name":"PETG"},"printer":{"id":1,"model":"Bambulab"}}],"user":{"id":2,"username":"aaa","country":{"name":"Canada"}}},{"id":11,"name":"User Request 6","budget":90.0,"comment":"This is request number 6 from user.","target_date":"2025-03-07","stl_file_url":"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MTIsInB1ciI6ImJsb2JfaWQifX0=--c9c27870feb4d1a4c48cbe3870a4e045cfb2aad2/RUBY13.stl","preset_requests":[],"user":{"id":2,"username":"aaa","country":{"name":"Canada"}}},{"id":12,"name":"User Request 7","budget":105.0,"comment":"This is request number 7 from user.","target_date":"2025-03-08","stl_file_url":"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MTMsInB1ciI6ImJsb2JfaWQifX0=--5fb4b5f51d00dfff7241ccc63f584c625a946df1/RUBY13.stl","preset_requests":[{"id":20,"print_quality":0.08,"color":{"id":1,"name":"Red"},"filament":{"id":1,"name":"PETG"},"printer":{"id":1,"model":"Bambulab"}},{"id":21,"print_quality":0.12,"color":{"id":2,"name":"Blue"},"filament":{"id":2,"name":"TPU"},"printer":{"id":2,"model":"Anycubic"}}],"user":{"id":2,"username":"aaa","country":{"name":"Canada"}}},{"id":13,"name":"User Request 8","budget":120.0,"comment":"This is request number 8 from user.","target_date":"2025-03-09","stl_file_url":"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MTQsInB1ciI6ImJsb2JfaWQifX0=--1ced4a77aaa9fa79186dd6bde8940164d3ee81ad/RUBY13.stl","preset_requests":[{"id":22,"print_quality":0.08,"color":{"id":1,"name":"Red"},"filament":{"id":1,"name":"PETG"},"printer":{"id":1,"model":"Bambulab"}},{"id":23,"print_quality":0.12,"color":{"id":2,"name":"Blue"},"filament":{"id":2,"name":"TPU"},"printer":{"id":2,"model":"Anycubic"}},{"id":24,"print_quality":0.16,"color":{"id":3,"name":"Green"},"filament":{"id":3,"name":"Nylon"},"printer":{"id":3,"model":"Artillery"}}],"user":{"id":2,"username":"aaa","country":{"name":"Canada"}}},{"id":14,"name":"User Request 9","budget":135.0,"comment":"This is request number 9 from user.","target_date":"2025-03-10","stl_file_url":"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MTUsInB1ciI6ImJsb2JfaWQifX0=--b914f6782f0c9d8af494f8c7df83de8b9ea5f6b9/RUBY13.stl","preset_requests":[{"id":25,"print_quality":0.08,"color":{"id":1,"name":"Red"},"filament":{"id":1,"name":"PETG"},"printer":{"id":1,"model":"Bambulab"}}],"user":{"id":2,"username":"aaa","country":{"name":"Canada"}}},{"id":15,"name":"User Request 10","budget":150.0,"comment":"This is request number 10 from user.","target_date":"2025-03-11","stl_file_url":"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MTYsInB1ciI6ImJsb2JfaWQifX0=--9acba983b9dd3f20861b779607746b6a7192c678/RUBY13.stl","preset_requests":[{"id":26,"print_quality":0.08,"color":{"id":1,"name":"Red"},"filament":{"id":1,"name":"PETG"},"printer":{"id":1,"model":"Bambulab"}},{"id":27,"print_quality":0.12,"color":{"id":2,"name":"Blue"},"filament":{"id":2,"name":"TPU"},"printer":{"id":2,"model":"Anycubic"}}],"user":{"id":2,"username":"aaa","country":{"name":"Canada"}}}],"errors":{}}
    
      #validate if id, name, budget, comment, target_date, stl_file_url, preset_requests, user, country are present
      assert json_response['request'].all? { |r| r['id'] && r['name'] && r['budget'] && r['comment'] && r['target_date'] && r['stl_file_url'] && r['preset_requests'] && r['user'] && r['user']['country'] }
    end
  end
  

  test "should return user's own requests for 'my' type" do
    get api_request_index_url, params: { type: 'my' }
    assert_response :success

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end
    
    assert json_response['request'].all? { |r| r['user']['id'] == @user.id }
  end

  ### SHOW ACTION ###
  test "should show a specific request" do
    get api_request_url(@user_request.id), as: :json
    assert_response :success

    json_response = JSON.parse(response.body)
    assert_equal @user_request.id, json_response['request']['id']
  end

  test "should return error for nonexistent request" do
    get api_request_url(id: 9999), as: :json
    assert_response :not_found
  end

  ### CREATE ACTION ###
  test "should create request with valid parameters" do
    assert_difference('Request.count', 1) do
      post api_request_index_url, params: {
        request: {
          name: "New Request",
          comment: "This is a new request",
          budget: 100,
          target_date: 5.days.from_now.to_date,
          stl_file: fixture_file_upload('RUBY13.stl', 'application/octet-stream'),
          preset_requests_attributes: [
            { color_id: 1, filament_id: 1, printer_id: 1, print_quality: 0.1 }
          ]
        }
      }
    end

    assert_response :created
  end

  test "should not create request with invalid data" do

    assert_no_difference('Request.count') do
      post api_request_index_url, params: {
        request: { name: "", budget: -10, target_date: "2020-01-01" }
      }, as: :json
    end

    assert_response :unprocessable_entity
  end

  ### UPDATE ACTION ###
  test "should update request with valid data" do
    patch api_request_url(@user_request), params: {
      request: { name: "Updated Request", budget: 150 }
    }, as: :json

    assert_response :success
    @user_request.reload
    assert_equal "Updated Request", @user_request.name
  end

  test "should not allow user to update another user's request" do
    sign_in @other_user

    patch api_request_url(@user_request), params: {
      request: { name: "Hacked Update" }
    }, as: :json

    assert_response :forbidden
  end

  test "should not update request with invalid data" do
    patch api_request_url(@user_request), params: {
      request: { name: "" }
    }, as: :json

    assert_response :unprocessable_entity
  end

  ### DELETE ACTION ###
  test "should delete own request" do
    assert_difference('Request.count', -1) do
      delete api_request_url(@user_request), as: :json
    end

    assert_response :success
  end

  test "should not allow user to delete another user's request" do
    sign_in @other_user

    assert_no_difference('Request.count') do
      delete api_request_url(@user_request), as: :json
    end

    assert_response :forbidden
  end
end
