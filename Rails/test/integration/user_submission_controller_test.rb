require "test_helper"

class UserSubmissionControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
  setup do
    @user = users(:one)
    @contest = contests(:contest_one)
  end

  test "should get index" do
    assert_difference('Submission.count', 0) do
      get api_user_submission_index_url, params: { submission: { contest_id: @contest.id } }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_ressponse = JSON.parse(response.body)
    end
    
    assert_equal @parsed_ressponse["submissions"][0]["submissions"].length, @contest.submissions.length
    assert_equal @parsed_ressponse["submissions"][0]["submissions"][0]["user_id"], @contest.submissions[0].user_id
    assert_equal @parsed_ressponse["submissions"][0]["submissions"][0]["contest_id"], @contest.submissions[0].contest_id
    assert_equal @parsed_ressponse["submissions"][0]["submissions"][0]["name"], @contest.submissions[0].name
    assert_equal @parsed_ressponse["submissions"][0]["submissions"][0]["description"], @contest.submissions[0].description
    assert_equal @parsed_ressponse["submissions"][0]["submissions"][0]["created_at"], @contest.submissions[0].created_at.iso8601(3)
    assert_equal @parsed_ressponse["submissions"][0]["submissions"][0]["updated_at"], @contest.submissions[0].updated_at.iso8601(3)
    assert_equal @parsed_ressponse["submissions"][0]["submissions"][0]["stl_url"].split("/").last,  @contest.submissions[0].files.last.filename.to_s
    assert_equal @parsed_ressponse["submissions"][0]["submissions"][0]["image_url"].split("/").last,  @contest.submissions[0].files.first.filename.to_s
  end
end
