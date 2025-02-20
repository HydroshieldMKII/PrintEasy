require "test_helper"

class Api::ContestControllerTest < ActionDispatch::IntegrationTest
    include Devise::Test::IntegrationHelpers
    setup do
        sign_in users(:two)
    end

    test "should get index" do
        assert_difference('Contest.count', 0) do
            get api_contest_index_url
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :success

        assert_equal 2, @parsed_response["contests"].length
        
        assert_equal contests(:contest_one).id, @parsed_response["contests"][1]["id"]
        assert_equal contests(:contest_one).theme, @parsed_response["contests"][1]["theme"]
        assert_equal contests(:contest_one).description, @parsed_response["contests"][1]["description"]
        assert_equal contests(:contest_one).submission_limit, @parsed_response["contests"][1]["submission_limit"]
        assert_equal contests(:contest_one).start_at, @parsed_response["contests"][1]["start_at"]
        assert_equal contests(:contest_one).end_at, @parsed_response["contests"][1]["end_at"]
        assert_equal contests(:contest_one).deleted_at, @parsed_response["contests"][1]["deleted_at"]
        assert_equal contests(:contest_one).image_url, @parsed_response["contests"][1]["image_url"]

        assert_equal contests(:contest_two).id, @parsed_response["contests"][0]["id"]
        assert_equal contests(:contest_two).theme, @parsed_response["contests"][0]["theme"]
        assert_equal contests(:contest_two).description, @parsed_response["contests"][0]["description"]
        assert_equal contests(:contest_two).submission_limit, @parsed_response["contests"][0]["submission_limit"]
        assert_equal contests(:contest_two).start_at, @parsed_response["contests"][0]["start_at"]
        assert_equal contests(:contest_two).end_at, @parsed_response["contests"][0]["end_at"]
        assert_equal contests(:contest_two).deleted_at, @parsed_response["contests"][0]["deleted_at"]
        assert_equal contests(:contest_two).image_url, @parsed_response["contests"][0]["image_url"]
    end

    test "should get show" do
        assert_difference('Contest.count', 0) do
            get api_contest_url(contests(:contest_one).id)
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :success

        assert_equal contests(:contest_one).id, @parsed_response["contest"]["id"]
        assert_equal contests(:contest_one).theme, @parsed_response["contest"]["theme"]
        assert_equal contests(:contest_one).description, @parsed_response["contest"]["description"]
        assert_equal contests(:contest_one).submission_limit, @parsed_response["contest"]["submission_limit"]
        assert_equal contests(:contest_one).start_at, @parsed_response["contest"]["start_at"]
        assert_equal contests(:contest_one).end_at, @parsed_response["contest"]["end_at"]
        assert_equal contests(:contest_one).deleted_at, @parsed_response["contest"]["deleted_at"]
        assert_equal contests(:contest_one).image_url, @parsed_response["contest"]["image_url"]
    end

    test "should create contest" do
        assert_difference('Contest.count', 1) do
            post api_contest_index_url, params: { contest: { theme: "test", description: "test", submission_limit: 10, start_at: Time.now + 1.day ,image: fixture_file_upload(Rails.root.join("test/fixtures/files/chicken_bagel.jpg"), 'image/jpg') } }
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :success

        assert_equal "test", @parsed_response["contest"]["theme"]
        assert_equal "test", @parsed_response["contest"]["description"]
        assert_equal 10, @parsed_response["contest"]["submission_limit"]
        assert_equal (Time.now + 1.day).change(sec: 0), @parsed_response["contest"]["start_at"].to_datetime.change(sec: 0)
        assert_nil @parsed_response["contest"]["end_at"]
        assert_nil @parsed_response["contest"]["deleted_at"]
        assert_not_nil @parsed_response["contest"]["image_url"]
    end

    test "should update contest" do
        assert_difference('Contest.count', 0) do
            put api_contest_url(contests(:contest_one).id), params: { contest: { theme: "test", description: "test", submission_limit: 10, start_at: Time.now + 2.day, end_at: Time.now + 4.day, image: fixture_file_upload(Rails.root.join("test/fixtures/files/chicken_bagel.jpg"), 'image/jpg') } }
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :success

        assert_equal "test", @parsed_response["contest"]["theme"]
        assert_equal "test", @parsed_response["contest"]["description"]
        assert_equal 10, @parsed_response["contest"]["submission_limit"]
        assert_equal (Time.now + 2.day).change(sec: 0), @parsed_response["contest"]["start_at"].to_datetime.change(sec: 0)
        assert_equal (Time.now + 4.day).change(sec: 0), @parsed_response["contest"]["end_at"].to_datetime.change(sec: 0)
        assert_nil @parsed_response["contest"]["deleted_at"]
        assert_not_nil @parsed_response["contest"]["image_url"]
    end

    test "should destroy contest" do
        assert_difference('Contest.count', -1) do
            delete api_contest_url(contests(:contest_one).id)
        end
        
        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :success

        assert_not_nil @parsed_response["contest"]["deleted_at"]
        assert_equal Time.now.change(sec: 0), @parsed_response["contest"]["deleted_at"].to_datetime.change(sec: 0)
    end

    test "should not get show -> contest not found" do
        assert_difference('Contest.count', 0) do
            get api_contest_url(0)
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :not_found
        assert_equal ["Contest not found"], @parsed_response["errors"]["contest"]
    end

    test "should not update contest -> contest not found" do
        assert_difference('Contest.count', 0) do
            put api_contest_url(0), params: { contest: { theme: "test", description: "test", submission_limit: 10, start_at: Time.now + 2.day, end_at: Time.now + 4.day, image: fixture_file_upload(Rails.root.join("test/fixtures/files/chicken_bagel.jpg"), 'image/jpg') } }
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :not_found
        assert_equal ["Contest not found"], @parsed_response["errors"]["contest"]
    end

    test "should not destroy contest -> contest not found" do
        assert_difference('Contest.count', 0) do
            delete api_contest_url(0)
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :not_found
        assert_equal ["Contest not found"], @parsed_response["errors"]["contest"]
    end
    
    test "should not create contest -> no contest" do
        assert_difference('Contest.count', 0) do
            post api_contest_index_path, params: {}
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :unprocessable_entity
        assert_equal ["param is missing or the value is empty: contest"], @parsed_response["errors"]["base"]
    end

    test "should not create contest -> no theme" do
        assert_difference('Contest.count', 0) do
            post api_contest_index_path, params: { contest: { description: "test", submission_limit: 10, start_at: Time.now + 1.day, image: fixture_file_upload(Rails.root.join("test/fixtures/files/chicken_bagel.jpg"), 'image/jpg') } }
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :unprocessable_entity
        assert_equal ["can't be blank"], @parsed_response["errors"]["theme"]
    end

    test "should not create contest -> description too long" do
        assert_difference('Contest.count', 0) do
            post api_contest_index_path, params: { contest: { theme: "test", description: "a" * 201, submission_limit: 10, start_at: Time.now + 1.day, image: fixture_file_upload(Rails.root.join("test/fixtures/files/chicken_bagel.jpg"), 'image/jpg') } }
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :unprocessable_entity
        @parsed_response["errors"]["description"]
        assert_equal ["is too long (maximum is 200 characters)"], @parsed_response["errors"]["description"]
    end

    test "should create contest -> no submisson limit" do
        assert_difference('Contest.count', 1) do
            post api_contest_index_path, params: { contest: { theme: "test", description: "test", start_at: Time.now + 1.day, image: fixture_file_upload(Rails.root.join("test/fixtures/files/chicken_bagel.jpg"), 'image/jpg') } }
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :success
        
        assert_equal 1, @parsed_response["contest"]["submission_limit"]
    end

    test "should not create contest -> no image" do
        assert_difference('Contest.count', 0) do
            post api_contest_index_path, params: { contest: { theme: "test", description: "test", submission_limit: 10, start_at: Time.now + 1.day } }
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :unprocessable_entity
        assert_equal ["can't be blank"], @parsed_response["errors"]["image"]
    end

    test "should not update contest -> no contest" do
        assert_difference('Contest.count', 0) do
            put api_contest_url(contests(:contest_one).id), params: {}
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :unprocessable_entity
        assert_equal ["param is missing or the value is empty: contest"], @parsed_response["errors"]["base"]
    end

    test "should not update contest -> theme empty" do
        assert_difference('Contest.count', 0) do
            put api_contest_url(contests(:contest_one).id), params: { contest: { theme: "", description: "test", submission_limit: 10, start_at: Time.now + 1.day, image: fixture_file_upload(Rails.root.join("test/fixtures/files/chicken_bagel.jpg"), 'image/jpg') } }
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :unprocessable_entity
        assert_equal ["can't be blank"], @parsed_response["errors"]["theme"]
    end

    test "should not update contest -> description too long" do
        assert_difference('Contest.count', 0) do
            put api_contest_url(contests(:contest_one).id), params: { contest: { theme: "test", description: "a" * 201, submission_limit: 10, start_at: Time.now + 1.day, image: fixture_file_upload(Rails.root.join("test/fixtures/files/chicken_bagel.jpg"), 'image/jpg') } }
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :unprocessable_entity
        assert_equal ["is too long (maximum is 200 characters)"], @parsed_response["errors"]["description"]
    end

    test "should not update contest -> no image" do
        assert_difference('Contest.count', 0) do
            put api_contest_url(contests(:contest_one).id), params: { contest: { theme: "test", description: "test", submission_limit: 10, start_at: Time.now + 1.day, image: nil } }
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :unprocessable_entity
        assert_equal ["can't be blank"], @parsed_response["errors"]["image"]
    end

    test "should not create contest -> start_at in the past" do
        assert_difference('Contest.count', 0) do
            post api_contest_index_path, params: { contest: { theme: "test", description: "test", submission_limit: 10, start_at: Time.now - 1.day, image: fixture_file_upload(Rails.root.join("test/fixtures/files/chicken_bagel.jpg"), 'image/jpg') } }
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :unprocessable_entity
        assert_equal ["must be in the future"], @parsed_response["errors"]["start_at"]
    end

    test "should not create contest -> end_at before start_at" do
        assert_difference('Contest.count', 0) do
            post api_contest_index_path, params: { contest: { theme: "test", description: "test", submission_limit: 10, start_at: Time.now + 1.day, end_at: Time.now, image: fixture_file_upload(Rails.root.join("test/fixtures/files/chicken_bagel.jpg"), 'image/jpg') } }
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :unprocessable_entity
        assert_equal ["must be at least one day after start_at"], @parsed_response["errors"]["end_at"]
    end

    test "should not update contest -> start_at in the past" do
        assert_difference('Contest.count', 0) do
            put api_contest_url(contests(:contest_one).id), params: { contest: { theme: "test", description: "test", submission_limit: 10, start_at: Time.now - 1.day, image: fixture_file_upload(Rails.root.join("test/fixtures/files/chicken_bagel.jpg"), 'image/jpg') } }
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :unprocessable_entity
        assert_equal ["must be in the future"], @parsed_response["errors"]["start_at"]
    end

    test "should not update contest -> end_at before start_at" do
        assert_difference('Contest.count', 0) do
            put api_contest_url(contests(:contest_one).id), params: { contest: { theme: "test", description: "test", submission_limit: 10, start_at: Time.now + 1.day, end_at: Time.now, image: fixture_file_upload(Rails.root.join("test/fixtures/files/chicken_bagel.jpg"), 'image/jpg') } }
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :unprocessable_entity
        assert_equal ["must be at least one day after start_at"], @parsed_response["errors"]["end_at"]
    end

    test "should not show contest if deleted -> contest found" do
        assert_difference('Contest.count', -1) do
            delete api_contest_url(contests(:contest_one).id)
        end

        assert_difference('Contest.count', 0) do
            get api_contest_url(contests(:contest_one).id)
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :not_found
        assert_equal ["Contest not found"], @parsed_response["errors"]["contest"]
    end

    test "should not update contest -> contest deleted" do
        assert_difference('Contest.count', -1) do
            delete api_contest_url(contests(:contest_one).id)
        end

        assert_difference('Contest.count', 0) do
            put api_contest_url(contests(:contest_one).id), params: { contest: { theme: "test", description: "test", submission_limit: 10, start_at: Time.now + 2.day, end_at: Time.now + 4.day, image: fixture_file_upload(Rails.root.join("test/fixtures/files/chicken_bagel.jpg"), 'image/jpg') } }
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :not_found
        assert_equal ["Contest not found"], @parsed_response["errors"]["contest"]
    end

    test "should not destroy contest -> contest deleted" do
        assert_difference('Contest.count', -1) do
            delete api_contest_url(contests(:contest_one).id)
        end

        assert_difference('Contest.count', 0) do
            delete api_contest_url(contests(:contest_one).id)
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :not_found
        assert_equal ["Contest not found"], @parsed_response["errors"]["contest"]
    end

    test "should not create contest -> no start_at" do
        assert_difference('Contest.count', 0) do
            post api_contest_index_path, params: { contest: { theme: "test", description: "test", submission_limit: 10, image: fixture_file_upload(Rails.root.join("test/fixtures/files/chicken_bagel.jpg"), 'image/jpg') } }
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :unprocessable_entity
        assert_equal ["can't be blank"], @parsed_response["errors"]["start_at"]
    end

    test "should not update contest -> no start_at" do
        assert_difference('Contest.count', 0) do
            put api_contest_url(contests(:contest_one).id), params: { contest: { theme: "test", description: "test", start_at: "", submission_limit: 10, image: fixture_file_upload(Rails.root.join("test/fixtures/files/chicken_bagel.jpg"), 'image/jpg') } }
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :unprocessable_entity
        assert_equal ["can't be blank"], @parsed_response["errors"]["start_at"]
    end

    test "should not create contest -> not admin" do
        sign_out users(:two)
        sign_in users(:one)

        assert_difference('Contest.count', 0) do
            post api_contest_index_path, params: { contest: { theme: "test", description: "test", submission_limit: 10, start_at: Time.now + 1.day, image: fixture_file_upload(Rails.root.join("test/fixtures/files/chicken_bagel.jpg"), 'image/jpg') } }
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :unauthorized
        assert_equal ["You must be an admin to perform this action"], @parsed_response["errors"]["contest"]
    end

    test "should not update contest -> not admin" do
        sign_out users(:two)
        sign_in users(:one)

        assert_difference('Contest.count', 0) do
            put api_contest_url(contests(:contest_one).id), params: { contest: { theme: "test", description: "test", submission_limit: 10, start_at: Time.now + 2.day, end_at: Time.now + 4.day, image: fixture_file_upload(Rails.root.join("test/fixtures/files/chicken_bagel.jpg"), 'image/jpg') } }
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :unauthorized
        assert_equal ["You must be an admin to perform this action"], @parsed_response["errors"]["contest"]
    end

    test "should not destroy contest -> not admin" do
        sign_out users(:two)
        sign_in users(:one)

        assert_difference('Contest.count', 0) do
            delete api_contest_url(contests(:contest_one).id)
        end

        assert_nothing_raised do
            @parsed_response = JSON.parse(response.body)
        end

        assert_response :unauthorized
        assert_equal ["You must be an admin to perform this action"], @parsed_response["errors"]["contest"]
    end
end