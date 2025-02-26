
require 'test_helper'

class OfferControllerTest < ActionDispatch::IntegrationTest
    setup do
        @user = users(:one)
        @other_user = users(:two)
        @offer = offers(:one)
        @offer.update(printer_user: printer_users(:one))
        sign_in @user
    end

    test "should get index" do
        get api_offers_url
        assert_response :success
    end

    test "should show offer" do
        get api_offer_url(@offer)
        assert_response :success
    end

    test "should not show offer if not owner" do
        sign_in @other_user
        get api_offer_url(@offer)
        assert_response :forbidden
    end

    test "should create offer" do
        assert_difference('Offer.count') do
            post api_offers_url, params: { offer: { request_id: requests(:one).id, printer_user_id: printer_users(:one).id, price: 100, print_quality: 'high', target_date: '2023-12-31' } }
        end
        assert_response :success
    end

    test "should update offer" do
        patch api_offer_url(@offer), params: { offer: { price: 150 } }
        assert_response :success
    end

    test "should not update offer if not owner" do
        sign_in @other_user
        patch api_offer_url(@offer), params: { offer: { price: 150 } }
        assert_response :unprocessable_entity
    end

    test "should destroy offer" do
        assert_difference('Offer.count', -1) do
            delete api_offer_url(@offer)
        end
        assert_response :success
    end

    test "should not destroy offer if not owner" do
        sign_in @other_user
        delete api_offer_url(@offer)
        assert_response :unprocessable_entity
    end

    test "should reject offer" do
        post reject_api_offer_url(@offer)
        assert_response :success
    end

    test "should not reject offer if not owner" do
        sign_in @other_user
        post reject_api_offer_url(@offer)
        assert_response :unprocessable_entity
    end
end