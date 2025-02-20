require 'test_helper'

class Api::RequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @other_user = users(:two)
    @user_request = requests(:request_one)
    @other_user_request = requests(:request_two)
    @preset = preset_requests(:preset_request_one)

    sign_in @user
  end

  ### INDEX ACTION ###
  test "should return all requests for 'all' type" do
    get api_request_index_path, params: { type: 'all' }
    assert_response :success
  
    json_response = assert_nothing_raised do
       JSON.parse(response.body)
    end

    assert json_response['request'].is_a?(Array)

    all_requests_not_mine = Request.where.not(user_id: @user.id)
    assert_equal all_requests_not_mine.count, json_response['request'].length

    # {"request":[{"id":6,"name":"User Request 1","budget":15.0,"comment":"This is request number 1 from user.","target_date":"2025-03-02","stl_file_url":"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6NywicHVyIjoiYmxvYl9pZCJ9fQ==--fc1ba8557eb636122cc8ed65e8d6c5b164305e33/RUBY13.stl","preset_requests":[{"id":10,"print_quality":0.08,"color":{"id":1,"name":"Red"},"filament":{"id":1,"name":"PETG"},"printer":{"id":1,"model":"Bambulab"}},{"id":11,"print_quality":0.12,"color":{"id":2,"name":"Blue"},"filament":{"id":2,"name":"TPU"},"printer":{"id":2,"model":"Anycubic"}},{"id":12,"print_quality":0.16,"color":{"id":3,"name":"Green"},"filament":{"id":3,"name":"Nylon"},"printer":{"id":3,"model":"Artillery"}}],"user":{"id":2,"username":"aaa","country":{"name":"Canada"}}},{"id":7,"name":"User Request 2","budget":30.0,"comment":"This is request number 2 from user.","target_date":"2025-03-03","stl_file_url":"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6OCwicHVyIjoiYmxvYl9pZCJ9fQ==--1d63d35dee7862b7b74d2b0b1b2897c89c95351c/RUBY13.stl","preset_requests":[],"user":{"id":2,"username":"aaa","country":{"name":"Canada"}}},{"id":8,"name":"User Request 3","budget":45.0,"comment":"This is request number 3 from user.","target_date":"2025-03-04","stl_file_url":"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6OSwicHVyIjoiYmxvYl9pZCJ9fQ==--e50f2dd8a98053b8a8d7af299ee7a977caefbe8d/RUBY13.stl","preset_requests":[{"id":13,"print_quality":0.08,"color":{"id":1,"name":"Red"},"filament":{"id":1,"name":"PETG"},"printer":{"id":1,"model":"Bambulab"}},{"id":14,"print_quality":0.12,"color":{"id":2,"name":"Blue"},"filament":{"id":2,"name":"TPU"},"printer":{"id":2,"model":"Anycubic"}},{"id":15,"print_quality":0.16,"color":{"id":3,"name":"Green"},"filament":{"id":3,"name":"Nylon"},"printer":{"id":3,"model":"Artillery"}}],"user":{"id":2,"username":"aaa","country":{"name":"Canada"}}},{"id":9,"name":"User Request 4","budget":60.0,"comment":"This is request number 4 from user.","target_date":"2025-03-05","stl_file_url":"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MTAsInB1ciI6ImJsb2JfaWQifX0=--74bdc50f681e4573fa8e58048fa36973b463ee45/RUBY13.stl","preset_requests":[{"id":16,"print_quality":0.08,"color":{"id":1,"name":"Red"},"filament":{"id":1,"name":"PETG"},"printer":{"id":1,"model":"Bambulab"}},{"id":17,"print_quality":0.12,"color":{"id":2,"name":"Blue"},"filament":{"id":2,"name":"TPU"},"printer":{"id":2,"model":"Anycubic"}},{"id":18,"print_quality":0.16,"color":{"id":3,"name":"Green"},"filament":{"id":3,"name":"Nylon"},"printer":{"id":3,"model":"Artillery"}}],"user":{"id":2,"username":"aaa","country":{"name":"Canada"}}},{"id":10,"name":"User Request 5","budget":75.0,"comment":"This is request number 5 from user.","target_date":"2025-03-06","stl_file_url":"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MTEsInB1ciI6ImJsb2JfaWQifX0=--397a37b94e71a3d19d7772120f47d4e3361b398b/RUBY13.stl","preset_requests":[{"id":19,"print_quality":0.08,"color":{"id":1,"name":"Red"},"filament":{"id":1,"name":"PETG"},"printer":{"id":1,"model":"Bambulab"}}],"user":{"id":2,"username":"aaa","country":{"name":"Canada"}}},{"id":11,"name":"User Request 6","budget":90.0,"comment":"This is request number 6 from user.","target_date":"2025-03-07","stl_file_url":"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MTIsInB1ciI6ImJsb2JfaWQifX0=--c9c27870feb4d1a4c48cbe3870a4e045cfb2aad2/RUBY13.stl","preset_requests":[],"user":{"id":2,"username":"aaa","country":{"name":"Canada"}}},{"id":12,"name":"User Request 7","budget":105.0,"comment":"This is request number 7 from user.","target_date":"2025-03-08","stl_file_url":"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MTMsInB1ciI6ImJsb2JfaWQifX0=--5fb4b5f51d00dfff7241ccc63f584c625a946df1/RUBY13.stl","preset_requests":[{"id":20,"print_quality":0.08,"color":{"id":1,"name":"Red"},"filament":{"id":1,"name":"PETG"},"printer":{"id":1,"model":"Bambulab"}},{"id":21,"print_quality":0.12,"color":{"id":2,"name":"Blue"},"filament":{"id":2,"name":"TPU"},"printer":{"id":2,"model":"Anycubic"}}],"user":{"id":2,"username":"aaa","country":{"name":"Canada"}}},{"id":13,"name":"User Request 8","budget":120.0,"comment":"This is request number 8 from user.","target_date":"2025-03-09","stl_file_url":"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MTQsInB1ciI6ImJsb2JfaWQifX0=--1ced4a77aaa9fa79186dd6bde8940164d3ee81ad/RUBY13.stl","preset_requests":[{"id":22,"print_quality":0.08,"color":{"id":1,"name":"Red"},"filament":{"id":1,"name":"PETG"},"printer":{"id":1,"model":"Bambulab"}},{"id":23,"print_quality":0.12,"color":{"id":2,"name":"Blue"},"filament":{"id":2,"name":"TPU"},"printer":{"id":2,"model":"Anycubic"}},{"id":24,"print_quality":0.16,"color":{"id":3,"name":"Green"},"filament":{"id":3,"name":"Nylon"},"printer":{"id":3,"model":"Artillery"}}],"user":{"id":2,"username":"aaa","country":{"name":"Canada"}}},{"id":14,"name":"User Request 9","budget":135.0,"comment":"This is request number 9 from user.","target_date":"2025-03-10","stl_file_url":"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MTUsInB1ciI6ImJsb2JfaWQifX0=--b914f6782f0c9d8af494f8c7df83de8b9ea5f6b9/RUBY13.stl","preset_requests":[{"id":25,"print_quality":0.08,"color":{"id":1,"name":"Red"},"filament":{"id":1,"name":"PETG"},"printer":{"id":1,"model":"Bambulab"}}],"user":{"id":2,"username":"aaa","country":{"name":"Canada"}}},{"id":15,"name":"User Request 10","budget":150.0,"comment":"This is request number 10 from user.","target_date":"2025-03-11","stl_file_url":"/rails/active_storage/blobs/redirect/eyJfcmFpbHMiOnsiZGF0YSI6MTYsInB1ciI6ImJsb2JfaWQifX0=--9acba983b9dd3f20861b779607746b6a7192c678/RUBY13.stl","preset_requests":[{"id":26,"print_quality":0.08,"color":{"id":1,"name":"Red"},"filament":{"id":1,"name":"PETG"},"printer":{"id":1,"model":"Bambulab"}},{"id":27,"print_quality":0.12,"color":{"id":2,"name":"Blue"},"filament":{"id":2,"name":"TPU"},"printer":{"id":2,"model":"Anycubic"}}],"user":{"id":2,"username":"aaa","country":{"name":"Canada"}}}],"errors":{}}
  
    #validate if id, name, budget, comment, target_date, stl_file_url, preset_requests, user, country are present
    #Valide again other_user_request values
    assert_equal @other_user_request.id, json_response['request'][0]['id']
    assert_equal @other_user_request.name, json_response['request'][0]['name']
    assert_equal @other_user_request.budget, json_response['request'][0]['budget']
    assert_equal @other_user_request.comment, json_response['request'][0]['comment']
    assert_equal @other_user_request.target_date.to_s, json_response['request'][0]['target_date']
    assert_equal @other_user_request.stl_file_url, json_response['request'][0]['stl_file_url']
    assert_equal @other_user_request.preset_requests.count, json_response['request'][0]['preset_requests'].length
    assert_equal @other_user_request.preset_requests[0].color.id, json_response['request'][0]['preset_requests'][0]['color']['id']
    assert_equal @other_user_request.preset_requests[0].color.name, json_response['request'][0]['preset_requests'][0]['color']['name']
    assert_equal @other_user_request.preset_requests[0].filament.id, json_response['request'][0]['preset_requests'][0]['filament']['id']
    assert_equal @other_user_request.preset_requests[0].filament.name, json_response['request'][0]['preset_requests'][0]['filament']['name']
    assert_equal @other_user_request.preset_requests[0].printer.id, json_response['request'][0]['preset_requests'][0]['printer']['id']
    assert_equal @other_user_request.preset_requests[0].printer.model, json_response['request'][0]['preset_requests'][0]['printer']['model']
    assert_equal @other_user_request.preset_requests[0].print_quality, json_response['request'][0]['preset_requests'][0]['print_quality']
    assert_equal @other_user_request.user.id, json_response['request'][0]['user']['id']
    assert_equal @other_user_request.user.username, json_response['request'][0]['user']['username']
    assert_equal @other_user_request.user.country.name, json_response['request'][0]['user']['country']['name']
    assert_empty json_response['errors']
  end
  

  test "should return user's own requests for 'my' type" do
    get api_request_index_url, params: { type: 'my' }
    assert_response :success

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end
    
    assert json_response['request'].all? { |r| r['user']['id'] == @user.id }

    my_requests = Request.where(user_id: @user.id)
    assert_equal my_requests.count, json_response['request'].length

    assert_equal @user_request.id, json_response['request'][0]['id']
    assert_equal @user_request.name, json_response['request'][0]['name']
    assert_equal @user_request.budget, json_response['request'][0]['budget']
    assert_equal @user_request.comment, json_response['request'][0]['comment']
    assert_equal @user_request.target_date.to_s, json_response['request'][0]['target_date']
    assert_equal @user_request.stl_file_url, json_response['request'][0]['stl_file_url']
    assert_equal @user_request.preset_requests.count, json_response['request'][0]['preset_requests'].length
    assert_equal @user_request.preset_requests[0].color.id, json_response['request'][0]['preset_requests'][0]['color']['id']
    assert_equal @user_request.preset_requests[0].color.name, json_response['request'][0]['preset_requests'][0]['color']['name']
    assert_equal @user_request.preset_requests[0].filament.id, json_response['request'][0]['preset_requests'][0]['filament']['id']
    assert_equal @user_request.preset_requests[0].filament.name, json_response['request'][0]['preset_requests'][0]['filament']['name']
    assert_equal @user_request.preset_requests[0].printer.id, json_response['request'][0]['preset_requests'][0]['printer']['id']
    assert_equal @user_request.preset_requests[0].printer.model, json_response['request'][0]['preset_requests'][0]['printer']['model']
    assert_equal @user_request.preset_requests[0].print_quality, json_response['request'][0]['preset_requests'][0]['print_quality']
    assert_equal @user_request.user.id, json_response['request'][0]['user']['id']
    assert_equal @user_request.user.username, json_response['request'][0]['user']['username']
    assert_equal @user_request.user.country.name, json_response['request'][0]['user']['country']['name']
    assert_empty json_response['errors']
  end

  ### SHOW ACTION ###
  test "should show a specific request" do
    get api_request_url(@user_request.id), as: :json
    assert_response :success

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end
    
    assert_equal @user_request.id, json_response['request']['id']
    assert_equal @user_request.name, json_response['request']['name']
    assert_equal @user_request.budget, json_response['request']['budget']
    assert_equal @user_request.comment, json_response['request']['comment']
    assert_equal @user_request.target_date.to_s, json_response['request']['target_date']
    assert_equal @user_request.stl_file_url, json_response['request']['stl_file_url']
    assert_equal @user_request.preset_requests.count, json_response['request']['preset_requests'].length
    assert_equal @user_request.preset_requests[0].color.id, json_response['request']['preset_requests'][0]['color']['id']
    assert_equal @user_request.preset_requests[0].color.name, json_response['request']['preset_requests'][0]['color']['name']
    assert_equal @user_request.preset_requests[0].filament.id, json_response['request']['preset_requests'][0]['filament']['id']
    assert_equal @user_request.preset_requests[0].filament.name, json_response['request']['preset_requests'][0]['filament']['name']
    assert_equal @user_request.preset_requests[0].printer.id, json_response['request']['preset_requests'][0]['printer']['id']
    assert_equal @user_request.preset_requests[0].printer.model, json_response['request']['preset_requests'][0]['printer']['model']
    assert_equal @user_request.preset_requests[0].print_quality, json_response['request']['preset_requests'][0]['print_quality']
    assert_equal @user_request.user.id, json_response['request']['user']['id']
    assert_equal @user_request.user.username, json_response['request']['user']['username']
    assert_equal @user_request.user.country.name, json_response['request']['user']['country']['name']
    assert_empty json_response['errors']
  end

  test "should return error for nonexistent request" do
    get api_request_url(id: 9999), as: :json
    assert_response :not_found
    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal "Not Found", json_response['error']
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
          stl_file: fixture_file_upload(Rails.root.join("test/fixtures/files/RUBY13.stl"), 'application/octet-stream'),
          preset_requests_attributes: [
            { color_id: 1, filament_id: 1, printer_id: 1, print_quality: 0.1 }
          ]
        }
      }
    end

    assert_response :created

    #Check should return the created request
    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal "New Request", json_response['request']['name']
    assert_equal "This is a new request", json_response['request']['comment']
    assert_equal 100, json_response['request']['budget']
    assert_equal 5.days.from_now.to_date.to_s, json_response['request']['target_date']
    assert json_response['request']['stl_file_url'].present?
    assert_equal 1, json_response['request']['preset_requests'].length
    assert_equal 1, json_response['request']['preset_requests'][0]['color']['id']
    assert_equal 1, json_response['request']['preset_requests'][0]['filament']['id']
    assert_equal 1, json_response['request']['preset_requests'][0]['printer']['id']
    assert_equal 0.1, json_response['request']['preset_requests'][0]['print_quality']
    assert_empty json_response['errors']
  end

  test "should not create request with invalid data" do

    assert_no_difference('Request.count') do
      post api_request_index_url, params: {
        request: { name: "", budget: -10, target_date: "2020-01-01" }
      }, as: :json
    end

    assert_response :unprocessable_entity

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert json_response['errors'].key?('name')
    assert json_response['errors'].key?('budget')
    assert json_response['errors'].key?('target_date')
    assert json_response['errors'].key?('stl_file')
  end

  ### UPDATE ACTION ###
  test "should partially update request with valid data" do
    before_update = @user_request

    assert_difference('Request.count', 0) do
      patch api_request_url(@user_request), params: {
        request: { name: "Updated Request", budget: 999 }
      }, as: :json
    end

    assert_response :success
    @user_request.reload
    assert_equal "Updated Request", @user_request.name
    assert_equal 999, @user_request.budget

    #validate if other attribute didnt change

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    #Check which data changed
    @user_request.reload
    assert_equal before_update.name, json_response['request']['name']
    assert_equal before_update.budget, json_response['request']['budget']
    assert_equal before_update.comment, @user_request.comment
    assert_equal before_update.target_date, @user_request.target_date
    assert_equal before_update.stl_file_url, @user_request.stl_file_url
    assert_equal before_update.preset_requests.count, @user_request.preset_requests.count
    assert_equal before_update.preset_requests[0].color_id, @user_request.preset_requests[0].color_id
    assert_equal before_update.preset_requests[0].filament_id, @user_request.preset_requests[0].filament_id
    assert_equal before_update.preset_requests[0].printer_id, @user_request.preset_requests[0].printer_id
    assert_equal before_update.preset_requests[0].print_quality, @user_request.preset_requests[0].print_quality

    # Check if the response is correct
    assert_equal "Updated Request", json_response['request']['name']
    assert_equal 999, json_response['request']['budget']
    assert_equal @user_request.comment, json_response['request']['comment']
    assert_equal @user_request.target_date.to_s, json_response['request']['target_date']
    assert_equal @user_request.stl_file_url, json_response['request']['stl_file_url']
    assert_equal @user_request.preset_requests.count, json_response['request']['preset_requests'].length
    assert_equal @user_request.preset_requests[0].color.id, json_response['request']['preset_requests'][0]['color']['id']
    assert_equal @user_request.preset_requests[0].color.name, json_response['request']['preset_requests'][0]['color']['name']
    assert_equal @user_request.preset_requests[0].filament.id, json_response['request']['preset_requests'][0]['filament']['id']
    assert_equal @user_request.preset_requests[0].filament.name, json_response['request']['preset_requests'][0]['filament']['name']
    assert_equal @user_request.preset_requests[0].printer.id, json_response['request']['preset_requests'][0]['printer']['id']
    assert_equal @user_request.preset_requests[0].printer.model, json_response['request']['preset_requests'][0]['printer']['model']
    assert_equal @user_request.preset_requests[0].print_quality, json_response['request']['preset_requests'][0]['print_quality']
    assert_equal @user_request.user.id, json_response['request']['user']['id']
    assert_equal @user_request.user.username, json_response['request']['user']['username']
    assert_equal @user_request.user.country.name, json_response['request']['user']['country']['name']
    assert_empty json_response['errors']
  end

  test "should fully update request with valid data" do
    assert_difference('Request.count', 0) do
      patch api_request_url(@user_request), params: {
        request: {
          name: "Fully Updated Request",
          comment: "This is a fully updated request",
          budget: 999,
          target_date: "3000-01-01",
          stl_file: fixture_file_upload('base.stl', 'application/octet-stream'),
          preset_requests_attributes: [
            { id: @preset.id, color_id: 1, filament_id: 1, printer_id: 1, print_quality: 0.1, _destroy: true },
            { color_id: 2, filament_id: 2, printer_id: 2, print_quality: 0.2 }
          ]
        }
      }
      end

    assert_response :success
    @user_request.reload

    # Check if the data is correct
    assert_equal "Fully Updated Request", @user_request.name
    assert_equal "This is a fully updated request", @user_request.comment
    assert_equal 999, @user_request.budget
    assert_equal "3000-01-01", @user_request.target_date.to_s
    assert_equal "base.stl", @user_request.stl_file.filename.to_s
    assert_equal 1, @user_request.preset_requests.count
    assert_equal 2, @user_request.preset_requests[0].color_id
    assert_equal 2, @user_request.preset_requests[0].filament_id
    assert_equal 2, @user_request.preset_requests[0].printer_id
    assert_equal 0.2, @user_request.preset_requests[0].print_quality

    # Check if the response is correct
    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal "Fully Updated Request", json_response['request']['name']
    assert_equal "This is a fully updated request", json_response['request']['comment']
    assert_equal 999, json_response['request']['budget']
    assert_equal "3000-01-01", json_response['request']['target_date']
    assert json_response['request']['stl_file_url'].present?
    assert_equal 1, json_response['request']['preset_requests'].length
    assert_equal 2, json_response['request']['preset_requests'][0]['color']['id']
    assert_equal 2, json_response['request']['preset_requests'][0]['filament']['id']
    assert_equal 2, json_response['request']['preset_requests'][0]['printer']['id']
    assert_equal 0.2, json_response['request']['preset_requests'][0]['print_quality']
    assert_equal @user_request.user.id, json_response['request']['user']['id']
    assert_equal @user_request.user.username, json_response['request']['user']['username']
    assert_equal @user_request.user.country.name, json_response['request']['user']['country']['name']
    assert_empty json_response['errors']
  end

  test "should delete preset_requests" do
    assert_difference('PresetRequest.count', -1) do
      patch api_request_url(@user_request), params: {
        request: {
          name: "Fully Updated Request",
          comment: "This is a fully updated request",
          budget: 999,
          target_date: "3000-01-01",
          preset_requests_attributes: [
            { id: @preset.id, color_id: 1, filament_id: 1, printer_id: 1, print_quality: 0.1, _destroy: true }
          ]
        }
      }
    end

    assert_response :success
    @user_request.reload
    assert_equal 0, @user_request.preset_requests.count

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 0, json_response['request']['preset_requests'].length
    assert_empty json_response['errors']

    # Check if the response is correct
    assert_equal "Fully Updated Request", json_response['request']['name']
    assert_equal "This is a fully updated request", json_response['request']['comment']
    assert_equal 999, json_response['request']['budget']
    assert_equal "3000-01-01", json_response['request']['target_date']
    assert json_response['request']['stl_file_url'].present?
    assert_equal 0, json_response['request']['preset_requests'].length
    assert_equal @user_request.user.id, json_response['request']['user']['id']
    assert_equal @user_request.user.username, json_response['request']['user']['username']
    assert_equal @user_request.user.country.name, json_response['request']['user']['country']['name']
  end

  test "Data should not be updated if invalid" do
    assert_no_difference('Request.count') do
      patch api_request_url(@user_request), params: {
        request: { budget: -10, target_date: "1970-01-01" }
      }, as: :json
    end
    assert_response :unprocessable_entity

    assert_equal "Test Request", @user_request.reload.name
    assert_equal 100, @user_request.budget
    assert_equal "Test Comments", @user_request.comment
    assert_equal "2021-12-31", @user_request.target_date.to_s
    assert_equal "RUBY13.stl", @user_request.stl_file.filename.to_s
    assert_equal 1, @user_request.preset_requests.count

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal json_response['errors']['name'], ["must be filled"]
    assert_equal json_response['errors']['target_date'], ["must be greater than today"]
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
