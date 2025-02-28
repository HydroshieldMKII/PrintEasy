require "test_helper"

class LikeControllerTest < ActionDispatch::IntegrationTest
    setup do
        @user = users(:one)
        @submission = submissions(:submission_three)
        sign_in @user
    end

    test "should create like" do
        assert_difference('Like.count') do
            post api_like_index_url, params: { like: { user_id: @user.id, submission_id: @submission.id } }
        end

        assert_response :created

        assert_nothing_raised do
          @parsed_response = JSON.parse(response.body)
        end

        assert_equal @user.id, @parsed_response["like"]["user_id"]
        assert_equal @submission.id, @parsed_response["like"]["submission_id"]
    end

    test "should create like without user_id" do
        assert_difference('Like.count') do
            post api_like_index_url, params: { like: { submission_id: @submission.id } }
        end

        assert_response :created

        assert_nothing_raised do
          @parsed_response = JSON.parse(response.body)
        end

        assert_equal @user.id, @parsed_response["like"]["user_id"]
        assert_equal @submission.id, @parsed_response["like"]["submission_id"]
    end

    test "should destroy like" do
        assert_difference('Like.count', -1) do
            delete api_like_url(likes(:one))
        end

        assert_response :ok

        assert_nothing_raised do
          @parsed_response = JSON.parse(response.body)
        end

        assert_equal likes(:one).user_id, @parsed_response["like"]["user_id"]
        assert_equal likes(:one).submission_id, @parsed_response["like"]["submission_id"]
    end

    test "should not create like" do
        assert_no_difference('Like.count') do
            post api_like_index_url, params: { like: { user_id: likes(:one).user_id, submission_id: likes(:one).submission_id } }
        end

        assert_response :unprocessable_entity

        assert_nothing_raised do
          @parsed_response = JSON.parse(response.body)
        end

        assert_equal ["has already been taken"], @parsed_response["errors"]["user_id"]
    end

    test "should not create like for another user" do
        assert_difference('Like.count') do
            post api_like_index_url, params: { like: { user_id: users(:two).id, submission_id: @submission.id } }
        end

        assert_response :created

        assert_nothing_raised do
          @parsed_response = JSON.parse(response.body)
        end

        assert_equal @user.id, @parsed_response["like"]["user_id"]
        assert_equal @submission.id, @parsed_response["like"]["submission_id"]
    end

    test "should not create like without submission_id" do
        assert_no_difference('Like.count') do
            post api_like_index_url, params: { like: { user_id: @user.id } }
        end

        assert_response :unprocessable_entity

        assert_nothing_raised do
          @parsed_response = JSON.parse(response.body)
        end

        assert_equal ["must exist"], @parsed_response["errors"]["submission"]
    end

    test "should not destroy like if not owner" do
        assert_no_difference('Like.count') do
            delete api_like_url(likes(:two))
        end

        assert_response :not_found

        assert_nothing_raised do
          @parsed_response = JSON.parse(response.body)
        end

        assert_equal ["Couldn't find Like with 'id'=2 [WHERE `likes`.`user_id` = ?]"], @parsed_response["errors"]["base"]
    end

    test "should not destroy like if not found" do
        assert_no_difference('Like.count') do
            delete api_like_url(999)
        end

        assert_response :not_found

        assert_nothing_raised do
          @parsed_response = JSON.parse(response.body)
        end

        assert_equal ["Couldn't find Like with 'id'=999 [WHERE `likes`.`user_id` = ?]"], @parsed_response["errors"]["base"]
    end

    test "should not destroy like if not authenticated" do
        sign_out @user

        assert_no_difference('Like.count') do
            delete api_like_url(likes(:one))
        end

        assert_response :unauthorized

        assert_nothing_raised do
          @parsed_response = JSON.parse(response.body)
        end

        assert_equal ["Invalid login credentials"], @parsed_response["errors"]["connection"]
    end

    test "should not create like if not authenticated" do
        sign_out @user

        assert_no_difference('Like.count') do
            post api_like_index_url, params: { like: { user_id: @user.id, submission_id: @submission.id } }
        end

        assert_response :unauthorized

        assert_nothing_raised do
          @parsed_response = JSON.parse(response.body)
        end

        assert_equal ["Invalid login credentials"], @parsed_response["errors"]["connection"]
    end
end
