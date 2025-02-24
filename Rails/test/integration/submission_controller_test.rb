require "test_helper"

class Api::SubmissionControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  setup do
    @contest = contests(:contest_one)
    @submission = submissions(:submission_one)
    @user = users(:one)
    @stl_file = active_storage_blobs(:first_stl_file_blob)
    sign_in @user
  end

  test "should get index" do
    assert_difference('Submission.count', 0) do
      get api_submission_index_url, params: { submission: { contest_id: @contest.id } }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal @contest.submissions.count, @parsed_response["submissions"].count
    assert_equal @contest.submissions.first.name, @parsed_response["submissions"].first["name"]
    assert_equal @contest.submissions.first.description, @parsed_response["submissions"].first["description"]
    assert_equal @contest.submissions.first.stl_url, @parsed_response["submissions"].first["stl_url"]
    assert_equal @contest.submissions.first.image_url, @parsed_response["submissions"].first["image_url"]
    assert_equal @contest.submissions.first.likes.count, @parsed_response["submissions"].first["likes"].count
  end

  test "should show submission" do
    assert_difference('Submission.count', 0) do
      get api_submission_url(@submission)
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal @submission.name, @parsed_response["submission"]["name"]
    assert_equal @submission.description, @parsed_response["submission"]["description"]
    assert_equal @submission.stl_url, @parsed_response["submission"]["stl_url"]
    assert_equal @submission.image_url, @parsed_response["submission"]["image_url"]
    assert_equal @submission.likes.count, @parsed_response["submission"]["likes"].count
  end

  test "should create submission" do
    assert_difference('Submission.count') do
      post api_submission_index_url, params: { submission: { user_id: @user.id, contest_id: @contest.id, name: "New Submission", description: "New Description", files: [fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type)] } }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal "New Submission", @parsed_response["submission"]["name"]
    assert_equal "New Description", @parsed_response["submission"]["description"]
    assert_equal @contest.id, @parsed_response["submission"]["contest_id"]
    assert_equal @user.id, @parsed_response["submission"]["user_id"]
    assert_not_equal nil, @parsed_response["submission"]["stl_url"]
    assert_equal "RUBY13.stl", @parsed_response["submission"]["stl_url"].split("/").last
    assert_equal nil, @parsed_response["submission"]["image_url"]
  end

  test "should update submission" do
    assert_difference('Submission.count', 0) do
      patch api_submission_url(@submission), params: { submission: {user_id: @user.id, contest_id: @contest.id, name: "Updated Submission", description: "Updated Description", files: [fixture_file_upload("base.stl", @stl_file.content_type), fixture_file_upload("images.jpg", "image/jpg")] } }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal "Updated Submission", @parsed_response["submission"]["name"]
    assert_equal "Updated Description", @parsed_response["submission"]["description"]
    assert_not_equal nil, @parsed_response["submission"]["stl_url"]
    assert_equal "base.stl", @parsed_response["submission"]["stl_url"].split("/").last
    assert_not_equal nil, @parsed_response["submission"]["image_url"]
    assert_equal "images.jpg", @parsed_response["submission"]["image_url"].split("/").last
  end

  test "should destroy submission" do
    assert_difference('Submission.count', -1) do
      delete api_submission_url(@submission)
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal @submission.id, @parsed_response["submission"]["id"]
    assert_equal 0, @parsed_response["submission"]["likes"].count
  end

  test "should not create submission without name" do
    assert_difference('Submission.count', 0) do
      post api_submission_index_url, params: { submission: { user_id: @user.id, contest_id: @contest.id, description: "New Description", files: [fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type)] } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["can't be blank"], @parsed_response["errors"]["name"]
  end

  test "should not create submission without contest_id" do
    assert_difference('Submission.count', 0) do
      post api_submission_index_url, params: { submission: { user_id: @user.id, name: "New Submission", description: "New Description", files: [fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type)] } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["must exist", "can't be blank"], @parsed_response["errors"]["contest"]
  end

  test "should not create submission without files" do
    assert_difference('Submission.count', 0) do
      post api_submission_index_url, params: { submission: { user_id: @user.id, contest_id: @contest.id, name: "New Submission", description: "New Description" } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["can't be blank", "must have at least one attached file (STL)"], @parsed_response["errors"]["files"]
  end

  test "should not create submission with invalid file format" do
    assert_difference('Submission.count', 0) do
      post api_submission_index_url, params: { submission: { user_id: @user.id, contest_id: @contest.id, name: "New Submission", description: "New Description", files: [fixture_file_upload("images.jpg", "image/jpg")] } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["first file must be an STL file"], @parsed_response["errors"]["files"]
  end

  test "should not create submission with invalid image format" do
    assert_difference('Submission.count', 0) do
      post api_submission_index_url, params: { submission: { user_id: @user.id, contest_id: @contest.id, name: "New Submission", description: "New Description", files: [fixture_file_upload("base.stl", @stl_file.content_type), fixture_file_upload("base.stl", @stl_file.content_type)] } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["second file must be an image (JPG, JPEG, or PNG)"], @parsed_response["errors"]["files"]
  end

  test "should not create submission with more than two files" do
    assert_difference('Submission.count', 0) do
      post api_submission_index_url, params: { submission: { user_id: @user.id, contest_id: @contest.id, name: "New Submission", description: "New Description", files: [fixture_file_upload("base.stl", @stl_file.content_type), fixture_file_upload("images.jpg", "image/jpg"), fixture_file_upload("base.stl", @stl_file.content_type)] } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["must have at most two attached files"], @parsed_response["errors"]["files"]
  end

  test "should not update submission without name" do
    assert_difference('Submission.count', 0) do
      patch api_submission_url(@submission), params: { submission: {user_id: @user.id, contest_id: @contest.id, name: "", description: "Updated Description", files: [fixture_file_upload("base.stl", @stl_file.content_type)] } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["can't be blank"], @parsed_response["errors"]["name"]
  end

  test "should not update submission without contest_id" do
    assert_difference('Submission.count', 0) do
      patch api_submission_url(@submission), params: { submission: {user_id: @user.id, contest_id: nil, name: "Updated Submission", description: "Updated Description", files: [fixture_file_upload("base.stl", @stl_file.content_type)] } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["must exist", "can't be blank"], @parsed_response["errors"]["contest"]
  end

  test "should not update submission without files" do
    assert_difference('Submission.count', 0) do
      patch api_submission_url(@submission), params: { submission: {user_id: @user.id, contest_id: @contest.id, name: "Updated Submission", description: "Updated Description", files: [] } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["can't be blank", "must have at least one attached file (STL)"], @parsed_response["errors"]["files"]
  end

  test "should not update submission with invalid file format" do
    assert_difference('Submission.count', 0) do
      patch api_submission_url(@submission), params: { submission: {user_id: @user.id, contest_id: @contest.id, name: "Updated Submission", description: "Updated Description", files: [fixture_file_upload("images.jpg", "image/jpg")] } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["first file must be an STL file"], @parsed_response["errors"]["files"]
  end

  test "should not update submission with invalid image format" do
    assert_difference('Submission.count', 0) do
      patch api_submission_url(@submission), params: { submission: {user_id: @user.id, contest_id: @contest.id, name: "Updated Submission", description: "Updated Description", files: [fixture_file_upload("base.stl", @stl_file.content_type), fixture_file_upload("base.stl", @stl_file.content_type)] } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["second file must be an image (JPG, JPEG, or PNG)"], @parsed_response["errors"]["files"]
  end

  test "should not update submission with more than two files" do
    assert_difference('Submission.count', 0) do
      patch api_submission_url(@submission), params: { submission: {user_id: @user.id, contest_id: @contest.id, name: "Updated Submission", description: "Updated Description", files: [fixture_file_upload("base.stl", @stl_file.content_type), fixture_file_upload("images.jpg", "image/jpg"), fixture_file_upload("base.stl", @stl_file.content_type)] } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["must have at most two attached files"], @parsed_response["errors"]["files"]
  end

  test "should not update submission with invalid contest_id" do
    assert_difference('Submission.count', 0) do
      patch api_submission_url(@submission), params: { submission: {user_id: @user.id, contest_id: 9, name: "Updated Submission", description: "Updated Description", files: [fixture_file_upload("base.stl", @stl_file.content_type)] } }
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["must exist","can't be blank"], @parsed_response["errors"]["contest"]
  end

  test "should not destroy submission with invalid id" do
    assert_difference('Submission.count', 0) do
      delete api_submission_url(9), params: { submission: { user_id: @user.id } }
    end

    assert_response :not_found

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["Submission not found"], @parsed_response["errors"]["submission"]
  end

  test "should not update submission with invalid id" do
    assert_difference('Submission.count', 0) do
      patch api_submission_url(9), params: { submission: { user_id: @user.id, contest_id: @contest.id, name: "Updated Submission", description: "Updated Description", files: [fixture_file_upload("base.stl", @stl_file.content_type)] } }
    end

    assert_response :not_found

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["Submission not found"], @parsed_response["errors"]["submission"]
  end

  test "should not destroy submission with invalid user" do
    sign_out @user
    sign_in users(:two)

    assert_difference('Submission.count', 0) do
      delete api_submission_url(@submission)
    end

    assert_response :unauthorized

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["You are not authorized to perform this action"], @parsed_response["errors"]["user"]
  end

  test "should not destroy submission without login" do
    sign_out @user

    assert_difference('Submission.count', 0) do
      delete api_submission_url(@submission)
    end

    assert_response :unauthorized

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["Invalid login credentials"], @parsed_response["errors"]["connection"]
  end

  test "should not update submission without login" do
    sign_out @user

    assert_difference('Submission.count', 0) do
      patch api_submission_url(@submission), params: { submission: { user_id: @user.id, contest_id: @contest.id, name: "Updated Submission", description: "Updated Description", files: [fixture_file_upload("base.stl", @stl_file.content_type)] } }
    end

    assert_response :unauthorized

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["Invalid login credentials"], @parsed_response["errors"]["connection"]
  end

  test "should not create submission without login" do
    sign_out @user

    assert_difference('Submission.count', 0) do
      post api_submission_index_url, params: { submission: { user_id: @user.id, contest_id: @contest.id, name: "New Submission", description: "New Description", files: [fixture_file_upload(@stl_file.filename.to_s, @stl_file.content_type)] } }
    end

    assert_response :unauthorized

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["Invalid login credentials"], @parsed_response["errors"]["connection"]
  end

  test "should not show submission without login" do
    sign_out @user

    assert_difference('Submission.count', 0) do
      get api_submission_url(@submission)
    end

    assert_response :unauthorized

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["Invalid login credentials"], @parsed_response["errors"]["connection"]
  end

  test "should not get index without login" do
    sign_out @user

    assert_difference('Submission.count', 0) do
      get api_submission_index_url, params: { submission: { contest_id: @contest.id } }
    end

    assert_response :unauthorized

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["Invalid login credentials"], @parsed_response["errors"]["connection"]
  end

  test "should not get index without contest_id" do
    assert_difference('Submission.count', 0) do
      get api_submission_index_url
    end

    assert_response :unprocessable_entity

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["param is missing or the value is empty: submission"], @parsed_response["errors"]["base"]
  end

  test "should not show submission without id" do
    assert_difference('Submission.count', 0) do
      get api_submission_url(9)
    end

    assert_response :not_found

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["Submission not found"], @parsed_response["errors"]["submission"]
  end

  test "should not update submission without id" do
    assert_difference('Submission.count', 0) do
      patch api_submission_url(9), params: { submission: { user_id: @user.id, contest_id: @contest.id, name: "Updated Submission", description: "Updated Description", files: [fixture_file_upload("base.stl", @stl_file.content_type)] } }
    end

    assert_response :not_found

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["Submission not found"], @parsed_response["errors"]["submission"]
  end

  test "should not destroy submission without id" do
    assert_difference('Submission.count', 0) do
      delete api_submission_url(9)
    end

    assert_response :not_found

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["Submission not found"], @parsed_response["errors"]["submission"]
  end
end