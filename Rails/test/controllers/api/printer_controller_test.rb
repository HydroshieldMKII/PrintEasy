require 'test_helper'

class Api::PrintersControllerTest < ActionDispatch::IntegrationTest
    def setup
        @user = users(:one)
        @printer1 = printers(:one)
        @printer2 = printers(:two)

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

        expected_response = [
            {"id" => @printer1.id, "model" => @printer1.model},
            {"id" => @printer2.id, "model" => @printer2.model}
        ]

        assert_equal expected_response, json_response
    end
end