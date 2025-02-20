require 'test_helper'

class Api::PrinterUserControllerTest < ActionDispatch::IntegrationTest

    def setup
        @user = users(:one)
        @printer_user_one = printer_users(:one)
        @printer_user_two = printer_users(:two)

        sign_in @user
    end

    test 'should get index' do
        assert_difference 'PrinterUser.count', 0 do
            get api_printer_user_index_path, as: :json
        end
        assert_response :success

        json_response = assert_nothing_raised do
            JSON.parse(response.body)
        end

        expected_response = [
            {"id" => @printer_user_one.id, "acquired_date" => @printer_user_one.acquired_date.to_s, "printer" => {"id" => @printer_user_one.printer.id, "model" => @printer_user_one.printer.model}}
        ]

        assert_equal expected_response, json_response
    end
end