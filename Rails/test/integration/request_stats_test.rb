# frozen_string_literal: true

require 'test_helper'

class RequestStatsTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @user_request = requests(:request_one)
    @user_request2 = requests(:request_three)
    @other_user = users(:two)
    @other_user_request = requests(:request_two)
    @preset = preset_requests(:preset_request_one)
    @preset2 = preset_requests(:preset_request_two)
    sign_in @user
  end

  test 'should get stats with default parameters' do
    get api_request_index_path, params: { type: 'stats' }
    assert_response :success
    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end
    assert_equal 3, json_response['stats'].size
    assert_equal 2, json_response['stats'][0]['total_offers']
    assert_equal 0, json_response['stats'][0]['accepted_offers']
    assert_equal 0.0, json_response['stats'][0]['acceptance_rate_percent']
    assert_equal 0.0, json_response['stats'][0]['total_accepted_price']
    assert_equal(-173.5, json_response['stats'][0]['avg_price_diff'])
    assert_equal '-36.0', json_response['stats'][0]['avg_response_time_hours']
    assert_equal 1, json_response['stats'][1]['total_offers']
    assert_equal 0, json_response['stats'][1]['accepted_offers']
    assert_equal 0.0, json_response['stats'][1]['acceptance_rate_percent']
    assert_equal 0.0, json_response['stats'][1]['total_accepted_price']
    assert_equal(-197.5, json_response['stats'][1]['avg_price_diff'])
    assert_equal '0.0', json_response['stats'][1]['avg_response_time_hours']
    assert_equal 0, json_response['stats'][2]['total_offers']
    assert_equal 0, json_response['stats'][2]['accepted_offers']
    assert_equal 0.0, json_response['stats'][2]['acceptance_rate_percent']
    assert_equal 0.0, json_response['stats'][2]['total_accepted_price']
    assert_nil json_response['stats'][2]['avg_price_diff']
    assert_nil json_response['stats'][2]['avg_response_time_hours']
  end

  test 'should get stats with color filter' do
    get api_request_index_path, params: { type: 'stats', colorIds: '1,2' }
    assert_response :success
    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end
    assert json_response['stats'].size <= 3
    assert(json_response['stats'].all? { |stat| [1, 2].include?(stat['color_id']) })
  end

  test 'should get stats with filament filter' do
    get api_request_index_path, params: { type: 'stats', filamentIds: '1,3' }
    assert_response :success
    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end
    assert json_response['stats'].size <= 3
    assert(json_response['stats'].all? { |stat| [1, 3].include?(stat['filament_id']) })
  end

  test 'should get stats with date range filter' do
    get api_request_index_path, params: {
      type: 'stats',
      startDate: '2021-01-01',
      endDate: '2021-01-02'
    }
    assert_response :success
    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end
    assert_not_empty json_response['stats']
  end

  test 'should get stats sorted by total offers' do
    get api_request_index_path, params: {
      type: 'stats',
      sortCategory: 'total_offers',
      sort: 'desc'
    }
    assert_response :success
    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end
    assert_not_empty json_response['stats']

    total_offers = json_response['stats'].map { |stat| stat['total_offers'] }
    assert_equal total_offers.sort.reverse, total_offers
  end

  test 'should get stats sorted by acceptance rate' do
    get api_request_index_path, params: {
      type: 'stats',
      sortCategory: 'acceptance_rate',
      sort: 'desc'
    }
    assert_response :success
    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_not_empty json_response['stats']

    acceptance_rates = json_response['stats'].map { |stat| stat['acceptance_rate_percent'] }
    assert_equal acceptance_rates.sort.reverse, acceptance_rates
  end

  test 'should get stats sorted by total price' do
    get api_request_index_path, params: {
      type: 'stats',
      sortCategory: 'total_price',
      sort: 'desc'
    }
    assert_response :success
    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_not_empty json_response['stats']

    total_prices = json_response['stats'].map { |stat| stat['total_accepted_price'] }
    assert_equal total_prices.sort.reverse, total_prices
  end

  test 'should get stats sorted by avg price diff' do
    get api_request_index_path, params: {
      type: 'stats',
      sortCategory: 'avg_price_diff',
      sort: 'desc'
    }

    assert_response :success

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    price_diffs = json_response['stats'].map { |stat| stat['avg_price_diff'] }.compact
    assert_equal price_diffs.sort.reverse, price_diffs if price_diffs.size >= 2
  end

  test 'should get stats sorted by avg response time' do
    get api_request_index_path, params: {
      type: 'stats',
      sortCategory: 'avg_response_time',
      sort: 'desc'
    }

    assert_response :success

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    response_times = json_response['stats'].map do |stat|
      stat['avg_response_time_hours']&.to_f
    end.compact
    assert_equal response_times.sort.reverse, response_times if response_times.size >= 2
  end

  test 'should handle invalid date parameters gracefully' do
    get api_request_index_path, params: {
      type: 'stats',
      startDate: 'invalid-date',
      endDate: '2021-01-02'
    }
    assert_response :success

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    assert_not_nil json_response['stats']
  end

  test 'should get correct preset information' do
    get api_request_index_path, params: { type: 'stats' }

    assert_response :success

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    preset_stat = json_response['stats'].find { |stat| stat['preset_id'] == presets(:preset_one).id }
    assert_not_nil preset_stat
    assert_equal presets(:preset_one).color_id, preset_stat['color_id']
    assert_equal presets(:preset_one).filament_id, preset_stat['filament_id']
    assert_equal colors(:color_one).name, preset_stat['color_name']
    assert_equal filaments(:one).name, preset_stat['filament_name']
  end

  test 'should get combined stats from presets and offers' do
    new_preset = Preset.create!(
      user_id: @user.id,
      color_id: colors(:color_five).id,
      filament_id: filaments(:one).id,
      print_quality: 0.5
    )

    get api_request_index_path, params: { type: 'stats' }

    assert_response :success

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    user_preset_stat = json_response['stats'].find do |stat|
      stat['preset_id'] == new_preset.id &&
        stat['color_id'] == colors(:color_five).id &&
        stat['filament_id'] == filaments(:one).id
    end

    assert_not_nil user_preset_stat

    blue_pla_stat = json_response['stats'].find do |stat|
      stat['color_id'] == colors(:color_one).id &&
        stat['filament_id'] == filaments(:one).id
    end

    assert_not_nil blue_pla_stat
    assert blue_pla_stat['total_offers'].positive?

    new_preset.destroy
  end
end
