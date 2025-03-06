# frozen_string_literal: true

require 'test_helper'

class HomeControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    sign_in users(:one)
  end

  test 'should get index' do
    get api_home_index_url

    assert_response :success
    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end
    assert_nil @parsed_response['errors']
    assert_equal 3, @parsed_response['requests'].count
    assert_equal 4, @parsed_response['submissions'].count
    assert_equal 3, @parsed_response['contests'].count

    # REQUESTS
    @first_request = @parsed_response['requests'].first
    assert_nil @first_request['user_id']
    assert_nil @first_request['created_at']
    assert_nil @first_request['updated_at']
    assert_equal requests(:request_three).name, @first_request['name']
    assert_equal requests(:request_three).budget, @first_request['budget']
    assert_equal requests(:request_three).comment, @first_request['comment']
    assert_equal requests(:request_three).target_date.to_s, @first_request['target_date']
    assert_equal 1, @first_request['preset_requests'].count

    @preset_request = @first_request['preset_requests'].first
    assert_nil @preset_request['request_id']
    assert_nil @preset_request['color_id']
    assert_nil @preset_request['filament_id']
    assert_nil @preset_request['printer_id']

    @color = @preset_request['color']
    assert_equal colors(:color_three).id, @color['id']
    assert_equal colors(:color_three).name, @color['name']

    @filament = @preset_request['filament']
    assert_equal filaments(:three).id, @filament['id']
    assert_equal filaments(:three).name, @filament['name']

    @printer = @preset_request['printer']
    assert_equal printers(:three).id, @printer['id']
    assert_equal printers(:three).model, @printer['model']

    @request_user = @first_request['user']
    assert_equal users(:one).id, @request_user['id']
    assert_equal users(:one).username, @request_user['username']
    assert_nil @request_user['country_id']

    @country = @request_user['country']
    assert_equal countries(:one).name, @country['name']

    # SUBMISSIONS

    @first_submission = @parsed_response['submissions'].first
    assert_nil @first_submission['user_id']
    assert_equal 1, @first_submission['contest_id']
    assert_equal submissions(:submission_one).name, @first_submission['name']
    assert_equal submissions(:submission_one).description, @first_submission['description']
    assert_equal true, @first_submission['liked_by_current_user']

    @submission_user = @first_submission['user']
    assert_equal users(:one).id, @submission_user['id']
    assert_equal users(:one).username, @submission_user['username']
    assert_nil @submission_user['country_id']

    @country = @submission_user['country']
    assert_equal countries(:one).id, @country['id']
    assert_equal countries(:one).name, @country['name']

    @likes = @first_submission['likes']
    assert_equal 1, @likes.count
    assert_equal likes(:one).user_id, @likes.first['user_id']
    assert_equal likes(:one).submission_id, @likes.first['submission_id']

    # CONTESTS

    @first_contest = @parsed_response['contests'].first
    assert_equal contests(:contest_three).id, @first_contest['id']
    assert_equal contests(:contest_three).theme, @first_contest['theme']
    assert_equal contests(:contest_three).description, @first_contest['description']
    assert_equal contests(:contest_three).submission_limit, @first_contest['submission_limit']
    assert_equal contests(:contest_three).deleted_at, @first_contest['deleted_at']
    assert_equal contests(:contest_three).start_at.iso8601(3), @first_contest['start_at']
    assert_equal contests(:contest_three).end_at.iso8601(3), @first_contest['end_at']
    assert_equal 1, @first_contest['submissions'].count
    assert_equal true, @first_contest['finished?']
    assert_equal true, @first_contest['started?']
    assert_equal users(:one).id, @first_contest['winner_user']['id']
    assert_equal users(:one).username, @first_contest['winner_user']['username']
  end
end
