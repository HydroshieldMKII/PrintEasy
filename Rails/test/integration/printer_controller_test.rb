# frozen_string_literal: true

require 'test_helper'

class PrintersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:one)
    @printer1 = printers(:one)
    @printer2 = printers(:two)
    @printer3 = printers(:three)

    sign_in @user
  end

  test 'should get index' do
    assert_difference 'Printer.count', 0 do
      get api_printer_index_path, as: :json
    end
    assert_response :success

    json_response = assert_nothing_raised do
      JSON.parse(response.body)
    end

    expected_response = [{ 'id' => 1, 'model' => 'Bambulab' },
                         { 'id' => 2, 'model' => 'Creality' },
                         { 'id' => 3, 'model' => 'Prusa' },
                         { 'id' => 4, 'model' => 'Anycubic' }]

    assert_equal expected_response, json_response
  end
end
