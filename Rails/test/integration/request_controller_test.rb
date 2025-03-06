# frozen_string_literal: true

require 'test_helper'

class RequestsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user_request = requests(:request_one)
    @user_request2 = requests(:request_three)
    @user_request_no_offer = requests(:request_four)

    @other_user = users(:two)
    @other_user_request = requests(:request_two)

    @preset = preset_requests(:preset_request_one)
    @preset2 = preset_requests(:preset_request_two)

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
    assert_equal 1, json_response['request'].length

    assert_equal @other_user_request.id, json_response['request'][0]['id']
    assert_equal @other_user_request.name, json_response['request'][0]['name']
    assert_equal @other_user_request.budget, json_response['request'][0]['budget']
    assert_equal @other_user_request.comment, json_response['request'][0]['comment']
    assert_equal @other_user_request.target_date.to_s, json_response['request'][0]['target_date']
    assert_equal @other_user_request.stl_file_url, json_response['request'][0]['stl_file_url']
    assert_equal @other_user_request.preset_requests.count, json_response['request'][0]['preset_requests'].length
    assert_equal @other_user_request.preset_requests[0].color.id,
                 json_response['request'][0]['preset_requests'][0]['color']['id']
    assert_equal @other_user_request.preset_requests[0].color.name,
                 json_response['request'][0]['preset_requests'][0]['color']['name']
    assert_equal @other_user_request.preset_requests[0].filament.id,
                 json_response['request'][0]['preset_requests'][0]['filament']['id']
    assert_equal @other_user_request.preset_requests[0].filament.name,
                 json_response['request'][0]['preset_requests'][0]['filament']['name']
    assert_equal @other_user_request.preset_requests[0].printer.id,
                 json_response['request'][0]['preset_requests'][0]['printer']['id']
    assert_equal @other_user_request.preset_requests[0].printer.model,
                 json_response['request'][0]['preset_requests'][0]['printer']['model']
    assert_equal @other_user_request.preset_requests[0].print_quality.to_s,
                 json_response['request'][0]['preset_requests'][0]['print_quality']
    assert_equal @other_user_request.user.id, json_response['request'][0]['user']['id']
    assert_equal @other_user_request.user.username, json_response['request'][0]['user']['username']
    assert_equal @other_user_request.user.country.name, json_response['request'][0]['user']['country']['name']
    assert_empty json_response['errors']
  end

  test "should return user's own requests for 'mine' type" do
    get api_request_index_url, params: { type: 'mine' }
    assert_response :success

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert(json_response['request'].all? { |r| r['user']['id'] == @user.id })

    my_requests = Request.where(user: @user)
    assert_equal my_requests.count, json_response['request'].length

    request1 = json_response['request'][0]
    assert_equal @user_request.id, request1['id']
    assert_equal @user_request.name, request1['name']
    assert_equal @user_request.budget, request1['budget']
    assert_equal @user_request.comment, request1['comment']
    assert_equal @user_request.target_date.to_s, request1['target_date']
    assert_equal @user_request.stl_file_url, request1['stl_file_url']
    assert_equal true, request1['has_offer_made?']

    preset1 = request1['preset_requests'][0]
    assert_equal @preset.id, preset1['id']
    assert_equal @preset.print_quality.to_s, preset1['print_quality']
    assert_equal @preset.color.id, preset1['color']['id']
    assert_equal @preset.color.name, preset1['color']['name']
    assert_equal @preset.filament.id, preset1['filament']['id']
    assert_equal @preset.filament.name, preset1['filament']['name']
    assert_equal @preset.printer.id, preset1['printer']['id']
    assert_equal @preset.printer.model, preset1['printer']['model']

    request2 = json_response['request'][1]
    assert_equal @user_request2.id, request2['id']
    assert_equal @user_request2.name, request2['name']
    assert_equal @user_request2.budget, request2['budget']
    assert_equal @user_request2.comment, request2['comment']
    assert_equal @user_request2.target_date.to_s, request2['target_date']
    assert_equal @user_request2.stl_file_url, request2['stl_file_url']
    assert_equal true, request2['has_offer_made?']

    assert_equal true, json_response['has_printer']
    assert_empty json_response['errors']
  end

  ### SHOW ACTION ###
  test 'should show a specific request' do
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
    assert_equal @user_request.preset_requests[0].color.id,
                 json_response['request']['preset_requests'][0]['color']['id']
    assert_equal @user_request.preset_requests[0].color.name,
                 json_response['request']['preset_requests'][0]['color']['name']
    assert_equal @user_request.preset_requests[0].filament.id,
                 json_response['request']['preset_requests'][0]['filament']['id']
    assert_equal @user_request.preset_requests[0].filament.name,
                 json_response['request']['preset_requests'][0]['filament']['name']
    assert_equal @user_request.preset_requests[0].printer.id,
                 json_response['request']['preset_requests'][0]['printer']['id']
    assert_equal @user_request.preset_requests[0].printer.model,
                 json_response['request']['preset_requests'][0]['printer']['model']
    assert_equal @user_request.preset_requests[0].print_quality.to_s,
                 json_response['request']['preset_requests'][0]['print_quality']
    assert_equal @user_request.user.id, json_response['request']['user']['id']
    assert_equal @user_request.user.username, json_response['request']['user']['username']
    assert_equal @user_request.user.country.name, json_response['request']['user']['country']['name']
    assert_empty json_response['errors']
  end

  test 'should return error for nonexistent request' do
    get api_request_url(id: 9999), as: :json

    assert_response :not_found
    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal ["Couldn't find Request with 'id'=9999 [WHERE (`requests`.`user_id` = ? OR `requests`.`id` IS NOT NULL)]"],
                 json_response['errors']['base']
  end

  ### CREATE ACTION ###
  test 'should create request with valid parameters' do
    assert_difference('Request.count', 1) do
      post api_request_index_url, params: {
        request: {
          name: 'New Request',
          comment: 'This is a new request',
          budget: 100,
          target_date: 5.days.from_now.to_date,
          stl_file: fixture_file_upload(Rails.root.join('test/fixtures/files/RUBY13.stl'), 'application/octet-stream'),
          preset_requests_attributes: [
            { color_id: 1, filament_id: 1, printer_id: 1, print_quality: 0.1 }
          ]
        }
      }
    end

    assert_response :created

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 'New Request', json_response['request']['name']
    assert_equal 'This is a new request', json_response['request']['comment']
    assert_equal 100, json_response['request']['budget']
    assert_equal 5.days.from_now.to_date.to_s, json_response['request']['target_date']
    assert json_response['request']['stl_file_url'].present?
    assert_equal 1, json_response['request']['preset_requests'].length
    assert_equal 1, json_response['request']['preset_requests'][0]['color']['id']
    assert_equal 1, json_response['request']['preset_requests'][0]['filament']['id']
    assert_equal 1, json_response['request']['preset_requests'][0]['printer']['id']
    assert_equal '0.1', json_response['request']['preset_requests'][0]['print_quality']
    assert_empty json_response['errors']
  end

  test 'should create multiple preset_requests for a request' do
    assert_difference('Request.count', 1) do
      post api_request_index_url, params: {
        request: {
          name: 'Multiple Preset Requests',
          comment: 'This request has multiple preset requests',
          budget: 100,
          target_date: 5.days.from_now.to_date,
          stl_file: fixture_file_upload(Rails.root.join('test/fixtures/files/RUBY13.stl'), 'application/octet-stream'),
          preset_requests_attributes: [
            { color_id: 1, filament_id: 1, printer_id: 1, print_quality: 0.1 },
            { color_id: 2, filament_id: 2, printer_id: 2, print_quality: 0.2 }
          ]
        }
      }
    end

    assert_response :created

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 'Multiple Preset Requests', json_response['request']['name']
    assert_equal 'This request has multiple preset requests', json_response['request']['comment']
    assert_equal 100, json_response['request']['budget']
    assert_equal 5.days.from_now.to_date.to_s, json_response['request']['target_date']
    assert json_response ['request']['stl_file_url'].present?
    assert_equal 2, json_response['request']['preset_requests'].length # 2 preset_requests
    assert_equal 1, json_response['request']['preset_requests'][0]['color']['id']
    assert_equal 1, json_response['request']['preset_requests'][0]['filament']['id']
    assert_equal 1, json_response['request']['preset_requests'][0]['printer']['id']
    assert_equal '0.1', json_response['request']['preset_requests'][0]['print_quality']
    assert_equal 2, json_response['request']['preset_requests'][1]['color']['id']
    assert_equal 2, json_response['request']['preset_requests'][1]['filament']['id']
    assert_equal 2, json_response['request']['preset_requests'][1]['printer']['id']
    assert_equal '0.2', json_response['request']['preset_requests'][1]['print_quality']
    assert_empty json_response['errors']
  end

  test 'should not create request with invalid name' do
    assert_no_difference('Request.count') do
      post api_request_index_url, params: {
        request: { name: '', budget: -10, target_date: '2020-01-01' }
      }, as: :json
    end

    assert_response :unprocessable_entity

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal "can't be blank", json_response['errors']['name'][0]
  end

  test 'should not create request with invalid date' do
    assert_no_difference('Request.count') do
      post api_request_index_url, params: {
        request: {
          name: 'Invalid Date Request',
          comment: 'This request has an invalid date',
          budget: 100,
          target_date: '1970-01-01',
          stl_file: fixture_file_upload(Rails.root.join('test/fixtures/files/RUBY13.stl'), 'application/octet-stream'),
          preset_requests_attributes: [
            { color_id: 1, filament_id: 1, printer_id: 1, print_quality: 0.1 }
          ]
        }
      }
    end

    assert_response :unprocessable_entity

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal ["must be greater than #{Date.today}"], json_response['errors']['target_date']
  end

  test 'should not create request with invalid budget' do
    assert_no_difference('Request.count') do
      post api_request_index_url, params: {
        request: {
          name: 'Invalid Budget Request',
          comment: 'This request has an invalid budget',
          budget: -10,
          target_date: 5.days.from_now.to_date,
          stl_file: fixture_file_upload(Rails.root.join('test/fixtures/files/RUBY13.stl'), 'application/octet-stream'),
          preset_requests_attributes: [
            { color_id: 1, filament_id: 1, printer_id: 1, print_quality: 0.1 }
          ]
        }
      }
    end

    assert_response :unprocessable_entity

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal ['must be greater than or equal to 0'], json_response['errors']['budget']
  end

  test 'should not create request with invalid preset_requests id' do
    assert_no_difference('Request.count') do
      post api_request_index_url, params: {
        request: {
          name: 'Invalid Preset Request ID',
          comment: 'This request has an invalid preset request id',
          budget: 100,
          target_date: 5.days.from_now.to_date,
          stl_file: fixture_file_upload(Rails.root.join('test/fixtures/files/RUBY13.stl'), 'application/octet-stream'),
          preset_requests_attributes: [
            { color_id: 999, filament_id: 999, printer_id: 999, print_quality: 100.1 }
          ]
        }
      }
    end

    assert_response :unprocessable_entity

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 'must exist', json_response['errors']['preset_requests.color'][0]
    assert_equal 'must exist', json_response['errors']['preset_requests.filament'][0]
    assert_equal 'must exist', json_response['errors']['preset_requests.printer'][0]
    assert_equal 'must be less than or equal to 2', json_response['errors']['preset_requests.print_quality'][0]
  end

  test 'should not create request with invalid stl_file' do
    assert_no_difference('Request.count') do
      post api_request_index_url, params: {
        request: {
          name: 'Invalid STL File Request',
          comment: 'This request has an invalid stl file',
          budget: 100,
          target_date: 5.days.from_now.to_date,
          stl_file: fixture_file_upload('test/fixtures/files/invalid.txt', 'text/plain'),
          preset_requests_attributes: [
            { color_id: 1, filament_id: 1, printer_id: 1, print_quality: 0.1 }
          ]
        }

      }
    end
    assert_response :unprocessable_entity

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 'must have .stl extension', json_response['errors']['stl_file'][0]
  end

  test 'should not create request with duplicated preset_requests' do
    assert_no_difference('Request.count') do
      post api_request_index_url, params: {
        request: {
          name: 'Duplicated Preset Request',
          comment: 'This request has duplicated preset requests',
          budget: 100,
          target_date: 5.days.from_now.to_date,
          stl_file: fixture_file_upload(Rails.root.join('test/fixtures/files/RUBY13.stl'), 'application/octet-stream'),
          preset_requests_attributes: [
            { color_id: 1, filament_id: 1, printer_id: 1, print_quality: 0.1 },
            { color_id: 1, filament_id: 1, printer_id: 1, print_quality: 0.1 }
          ]
        }
      }
    end

    assert_response :unprocessable_entity

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal ['Duplicate preset exists in the request'], json_response['errors']['base']
  end

  test 'should not update request with accepted offers' do
    assert_no_difference('Request.count') do
      patch api_request_url(@user_request), params: {
        request: { name: 'Updated Request' }
      }, as: :json
    end

    assert_response :unprocessable_entity

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 'Cannot update request with accepted offers', json_response['errors']['base'][0]
  end

  ### UPDATE ACTION ###
  test 'should partially update request with valid data' do
    assert_difference('Request.count', 0) do
      patch api_request_url( @user_request_no_offer), params: { request: { name: 'Updated Request', budget: 999 } }, as: :json
    end

    assert_response :success
    @user_request_no_offer.reload

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 'Updated Request', json_response['request']['name']
    assert_equal 999, json_response['request']['budget']
    assert_equal @user_request_no_offer.comment, json_response['request']['comment']
    assert_equal @user_request_no_offer.target_date.to_s, json_response['request']['target_date']
    assert_equal @user_request_no_offer.stl_file_url, json_response['request']['stl_file_url']
    assert_equal @user_request_no_offer.preset_requests.count, json_response['request']['preset_requests'].length
    assert_equal @user_request_no_offer.preset_requests[0].color.id,
                 json_response['request']['preset_requests'][0]['color']['id']
    assert_equal @user_request_no_offer.preset_requests[0].color.name,
                 json_response['request']['preset_requests'][0]['color']['name']
    assert_equal @user_request_no_offer.preset_requests[0].filament.id,
                 json_response['request']['preset_requests'][0]['filament']['id']
    assert_equal @user_request_no_offer.preset_requests[0].filament.name,
                 json_response['request']['preset_requests'][0]['filament']['name']
    assert_equal @user_request_no_offer.preset_requests[0].printer.id,
                 json_response['request']['preset_requests'][0]['printer']['id']
    assert_equal @user_request_no_offer.preset_requests[0].printer.model,
                 json_response['request']['preset_requests'][0]['printer']['model']
    assert_equal @user_request_no_offer.preset_requests[0].print_quality.to_s,
                 json_response['request']['preset_requests'][0]['print_quality']
    assert_equal @user_request_no_offer.user.id, json_response['request']['user']['id']
    assert_equal @user_request_no_offer.user.username, json_response['request']['user']['username']
    assert_equal @user_request_no_offer.user.country.name, json_response['request']['user']['country']['name']
    assert_empty json_response['errors']
  end

  test 'should fully update request with valid data' do
    # debugger
    patch api_request_url(@user_request_no_offer), params: {
      request: {
        name: 'Fully Updated Request',
        comment: 'This is a fully updated request',
        budget: 999,
        target_date: '3000-01-01',
        preset_requests_attributes: [
          { color_id: 2, filament_id: 2, printer_id: 2, print_quality: 0.2 }
        ]
      }
    }, as: :json

    assert_response :success
    @user_request_no_offer.reload

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 'Fully Updated Request', json_response['request']['name']
    assert_equal 'This is a fully updated request', json_response['request']['comment']
    assert_equal 999, json_response['request']['budget']
    assert_equal '3000-01-01', json_response['request']['target_date']

    assert_equal @user_request_no_offer.preset_requests.count, json_response['request']['preset_requests'].length

    first_preset = json_response['request']['preset_requests'][0]
    assert_not_nil first_preset['id']
    assert_equal 4, first_preset['color']['id']
    assert_equal 4, first_preset['filament']['id']
    assert_equal 4, first_preset['printer']['id']
    assert_equal '0.4', first_preset['print_quality']
    assert_empty json_response['errors']
  end

  test 'should delete preset_requests' do
    initial_count = @user_request_no_offer.preset_requests.count
    preset_to_delete =  @user_request_no_offer.preset_requests.first

    assert_difference('PresetRequest.count', -1) do
      patch api_request_url(@user_request_no_offer), params: {
        request: {
          name: 'Fully Updated Request',
          comment: 'This is a fully updated request',
          budget: 999,
          target_date: '3000-01-01',
          preset_requests_attributes: [
            { id: preset_to_delete.id, _destroy: true }
          ]
        }
      }
    end

    assert_response :success
    @user_request_no_offer.reload

    assert_equal initial_count - 1,  @user_request_no_offer.preset_requests.count
    assert_nil PresetRequest.find_by(id: preset_to_delete.id)

    json_response = JSON.parse(response.body)

    assert_equal initial_count - 1, json_response['request']['preset_requests'].length
    assert_empty json_response['errors']

    assert_equal 'Fully Updated Request', json_response['request']['name']
    assert_equal 'This is a fully updated request', json_response['request']['comment']
    assert_equal 999, json_response['request']['budget']
    assert_equal '3000-01-01', json_response['request']['target_date']
    assert json_response['request']['stl_file_url'].present?
    assert_equal @user_request2.user.id, json_response['request']['user']['id']
    assert_equal @user_request2.user.username, json_response['request']['user']['username']
    assert_equal @user_request2.user.country.name, json_response['request']['user']['country']['name']
  end

  test 'Data should not be updated if date is invalid' do
    assert_no_difference('Request.count') do
      patch api_request_url(@user_request2), params: {
        request: { name: 'abc', budget: 100, target_date: '1970-01-01' }
      }, as: :json
    end
    assert_response :unprocessable_entity

    assert_equal 'Test Request', @user_request.reload.name
    assert_equal 100, @user_request.budget
    assert_equal 'Test Comments', @user_request.comment
    assert_equal '2021-10-31', @user_request.target_date.to_s
    assert_equal 'RUBY13.stl', @user_request.stl_file.filename.to_s
    assert_equal 1, @user_request.preset_requests.count

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal json_response['errors']['target_date'], ['must be greater than today']
  end

  test 'should not allow user to update request with name' do
    assert_no_difference('Request.count') do
      patch api_request_url(@user_request2), params: {
        request: { name: '' }
      }, as: :json
    end

    assert_response :unprocessable_entity

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal "can't be blank", json_response['errors']['name'][0]
    assert_equal 'is too short (minimum is 3 characters)', json_response['errors']['name'][1]
  end

  test 'should not allow user to update request with budget too low' do
    sign_out @user
    sign_in @other_user

    assert_no_difference('Request.count') do
      patch api_request_url(@other_user_request), params: {
        request: { budget: -10 }
      }, as: :json
    end

    assert_response :unprocessable_entity

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 'must be greater than or equal to 0', json_response['errors']['budget'][0]
  end

  test 'should not allow user to update request with budget too high' do
    assert_no_difference('Request.count') do
      patch api_request_url(@user_request2), params: {
        request: { budget: 1_000_000 }
      }, as: :json
    end

    assert_response :unprocessable_entity

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 'must be less than or equal to 10000', json_response['errors']['budget'][0]
  end

  test 'should not allow user to update request with invalid stl_file' do
    assert_no_difference('Request.count') do
      patch api_request_url(@user_request2), params: {
        request: { stl_file: fixture_file_upload('test/fixtures/files/invalid.txt', 'text/plain') }
      }
    end

    assert_response :unprocessable_entity

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 'must have .stl extension', json_response['errors']['stl_file'][0]
  end

  test 'should not allow user to update request with invalid preset_requests data' do
    assert_no_difference('Request.count') do
      patch api_request_url(@user_request2), params: {
        request: {
          preset_requests_attributes: [
            { color_id: 1, filament_id: 1, printer_id: 1, print_quality: -0.1 }
          ]
        }
      }, as: :json
    end

    assert_response :unprocessable_entity

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal 'must be greater than 0', json_response['errors']['preset_requests.print_quality'][0]
  end

  test "should not allow user to update another user's request" do
    sign_out @user
    sign_in @other_user

    patch api_request_url(@user_request), params: {
      request: { name: 'Hacked Update' }
    }, as: :json

    assert_response :not_found

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal ["Couldn't find Request with 'id'=1 [WHERE `requests`.`user_id` = ?]"], json_response['errors']['base']
  end

  ### DELETE ACTION ###
  test 'should not delete request with accepted offer' do
    # debugger
    assert_difference('Request.count', 0) do
      delete api_request_url(@user_request)
    end

    assert_response :unprocessable_entity

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal ['Cannot delete request with accepted offers'], json_response['errors']['base']
  end

  test "should not allow user to delete another user's request" do
    sign_out @user
    sign_in @other_user

    assert_no_difference('Request.count') do
      delete api_request_url(@user_request), as: :json
    end

    assert_response :not_found

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_equal ["Couldn't find Request with 'id'=1 [WHERE `requests`.`user_id` = ?]"], json_response['errors']['base']
  end
end
