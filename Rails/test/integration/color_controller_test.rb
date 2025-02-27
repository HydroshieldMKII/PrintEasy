# frozen_string_literal: true

require 'test_helper'

class ColorControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @color1 = colors(:color_one)
    @color2 = colors(:color_two)

    sign_in @user
  end

  test 'should get index' do
    assert_difference 'Color.count', 0 do
      get api_color_index_path, as: :json
    end
    assert_response :success

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    expected_response = Color.all.map do |color|
      { 'id' => color.id, 'name' => color.name }
    end

    assert_equal expected_response, json_response
  end
end
