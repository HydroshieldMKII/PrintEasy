require "test_helper"

class LeaderboardControllerTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  setup do
    @user = users(:one)

    sign_in @user
  end

  test "should get index" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["wins_count"] >= @parsed_response["leaderboard"][1]["wins_count"]
    assert @parsed_response["leaderboard"][1]["wins_count"] >= @parsed_response["leaderboard"][2]["wins_count"]
  end

  test "should get index sort by wins asc" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "wins", direction: "asc" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["wins_count"] <= @parsed_response["leaderboard"][1]["wins_count"]
    assert @parsed_response["leaderboard"][1]["wins_count"] <= @parsed_response["leaderboard"][2]["wins_count"]
  end

  test "should get index sort by wins desc" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "wins", direction: "desc" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["wins_count"] >= @parsed_response["leaderboard"][1]["wins_count"]
    assert @parsed_response["leaderboard"][1]["wins_count"] >= @parsed_response["leaderboard"][2]["wins_count"]
  end

  test "should get index sort by submissions_participation asc" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "submission_rate", direction: "asc" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["submissions_participation"].to_f <= @parsed_response["leaderboard"][1]["submissions_participation"].to_f
    assert @parsed_response["leaderboard"][1]["submissions_participation"].to_f <= @parsed_response["leaderboard"][2]["submissions_participation"].to_f
  end

  test "should get index sort by submissions_participation desc" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "submission_rate", direction: "desc" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["submissions_participation"].to_f >= @parsed_response["leaderboard"][1]["submissions_participation"].to_f
    assert @parsed_response["leaderboard"][1]["submissions_participation"].to_f >= @parsed_response["leaderboard"][2]["submissions_participation"].to_f
  end

  test "should get index sort by participations asc" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "participations", direction: "asc" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["participations"] <= @parsed_response["leaderboard"][1]["participations"]
    assert @parsed_response["leaderboard"][1]["participations"] <= @parsed_response["leaderboard"][2]["participations"]
  end

  test "should get index sort by participations desc" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "participations", direction: "desc" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["participations"] >= @parsed_response["leaderboard"][1]["participations"]
    assert @parsed_response["leaderboard"][1]["participations"] >= @parsed_response["leaderboard"][2]["participations"]
  end

  test "should get index sort by total_likes asc" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "total_likes", direction: "asc" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["total_likes"] <= @parsed_response["leaderboard"][1]["total_likes"]
    assert @parsed_response["leaderboard"][1]["total_likes"] <= @parsed_response["leaderboard"][2]["total_likes"]
  end

  test "should get index sort by total_likes desc" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "total_likes", direction: "desc" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["total_likes"] >= @parsed_response["leaderboard"][1]["total_likes"]
    assert @parsed_response["leaderboard"][1]["total_likes"] >= @parsed_response["leaderboard"][2]["total_likes"]
  end

  test "should get index sort by winrate asc" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "winrate", direction: "asc" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["winrate"].to_f <= @parsed_response["leaderboard"][1]["winrate"].to_f
    assert @parsed_response["leaderboard"][1]["winrate"].to_f <= @parsed_response["leaderboard"][2]["winrate"].to_f
  end

  test "should get index sort by winrate desc" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "winrate", direction: "desc" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["winrate"].to_f >= @parsed_response["leaderboard"][1]["winrate"].to_f
    assert @parsed_response["leaderboard"][1]["winrate"].to_f >= @parsed_response["leaderboard"][2]["winrate"].to_f
  end

  test "should get index with start_date and end_date" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { start_date: "2024-01-01", end_date: Date.today.to_s }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["wins_count"] >= @parsed_response["leaderboard"][1]["wins_count"]
    assert @parsed_response["leaderboard"][1]["wins_count"] >= @parsed_response["leaderboard"][2]["wins_count"]
  end

  test "should get index with start_date and end_date reversed" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { start_date: Date.today.to_s, end_date: "2024-01-01" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["wins_count"] >= @parsed_response["leaderboard"][1]["wins_count"]
    assert @parsed_response["leaderboard"][1]["wins_count"] >= @parsed_response["leaderboard"][2]["wins_count"]
  end

  test "should get index with start_date and end_date reversed and invalid" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { start_date: "2024-01-01", end_date: "2023-01-01" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["wins_count"] >= @parsed_response["leaderboard"][1]["wins_count"]
    assert @parsed_response["leaderboard"][1]["wins_count"] >= @parsed_response["leaderboard"][2]["wins_count"]
  end

  test "should get index sort by wins asc with start_date and end_date" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "wins", direction: "asc", start_date: "2024-01-01", end_date: Date.today.to_s }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["wins_count"] <= @parsed_response["leaderboard"][1]["wins_count"]
    assert @parsed_response["leaderboard"][1]["wins_count"] <= @parsed_response["leaderboard"][2]["wins_count"]
  end

  test "should get index sort by wins desc with start_date and end_date" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "wins", direction: "desc", start_date: "2024-01-01", end_date: Date.today.to_s }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["wins_count"] >= @parsed_response["leaderboard"][1]["wins_count"]
    assert @parsed_response["leaderboard"][1]["wins_count"] >= @parsed_response["leaderboard"][2]["wins_count"]
  end

  test "should get index sort by submissions_participation asc with start_date and end_date" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "submission_rate", direction: "asc", start_date: "2024-01-01", end_date: Date.today.to_s }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["submissions_participation"].to_f <= @parsed_response["leaderboard"][1]["submissions_participation"].to_f
    assert @parsed_response["leaderboard"][1]["submissions_participation"].to_f <= @parsed_response["leaderboard"][2]["submissions_participation"].to_f
  end

  test "should get index sort by submissions_participation desc with start_date and end_date" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "submission_rate", direction: "desc", start_date: "2024-01-01", end_date: Date.today.to_s }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["submissions_participation"].to_f >= @parsed_response["leaderboard"][1]["submissions_participation"].to_f
    assert @parsed_response["leaderboard"][1]["submissions_participation"].to_f >= @parsed_response["leaderboard"][2]["submissions_participation"].to_f
  end

  test "should get index sort by participations asc with start_date and end_date" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "participations", direction: "asc", start_date: "2024-01-01", end_date: Date.today.to_s }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["participations"] <= @parsed_response["leaderboard"][1]["participations"]
    assert @parsed_response["leaderboard"][1]["participations"] <= @parsed_response["leaderboard"][2]["participations"]
  end

  test "should get index sort by participations desc with start_date and end_date" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "participations", direction: "desc", start_date: "2024-01-01", end_date: Date.today.to_s }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["participations"] >= @parsed_response["leaderboard"][1]["participations"]
    assert @parsed_response["leaderboard"][1]["participations"] >= @parsed_response["leaderboard"][2]["participations"]
  end

  test "should get index sort by total_likes asc with start_date and end_date" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "total_likes", direction: "asc", start_date: "2024-01-01", end_date: Date.today.to_s }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["total_likes"] <= @parsed_response["leaderboard"][1]["total_likes"]
    assert @parsed_response["leaderboard"][1]["total_likes"] <= @parsed_response["leaderboard"][2]["total_likes"]
  end

  test "should get index sort by total_likes desc with start_date and end_date" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "total_likes", direction: "desc", start_date: "2024-01-01", end_date: Date.today.to_s }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["total_likes"] >= @parsed_response["leaderboard"][1]["total_likes"]
    assert @parsed_response["leaderboard"][1]["total_likes"] >= @parsed_response["leaderboard"][2]["total_likes"]
  end

  test "should get index sort by winrate asc with start_date and end_date" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "winrate", direction: "asc", start_date: "2024-01-01", end_date: Date.today.to_s }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["winrate"].to_f <= @parsed_response["leaderboard"][1]["winrate"].to_f
    assert @parsed_response["leaderboard"][1]["winrate"].to_f <= @parsed_response["leaderboard"][2]["winrate"].to_f
  end

  test "should get index sort by winrate desc with start_date and end_date" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "winrate", direction: "desc", start_date: "2024-01-01", end_date: Date.today.to_s }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["winrate"].to_f >= @parsed_response["leaderboard"][1]["winrate"].to_f
    assert @parsed_response["leaderboard"][1]["winrate"].to_f >= @parsed_response["leaderboard"][2]["winrate"].to_f
  end

  test "should get index with invalid start_date and end_date" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { start_date: "2024-01-01", end_date: "2023-01-01" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["wins_count"] >= @parsed_response["leaderboard"][1]["wins_count"]
    assert @parsed_response["leaderboard"][1]["wins_count"] >= @parsed_response["leaderboard"][2]["wins_count"]
  end

  test "should get index with wrong start_date format" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { start_date: "miguel", end_date: "01-01-2023" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["wins_count"] >= @parsed_response["leaderboard"][1]["wins_count"]
    assert @parsed_response["leaderboard"][1]["wins_count"] >= @parsed_response["leaderboard"][2]["wins_count"]
  end

  test "should get index with wrong end_date format" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { start_date: "2024-01-01", end_date: "miguel" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["wins_count"] >= @parsed_response["leaderboard"][1]["wins_count"]
    assert @parsed_response["leaderboard"][1]["wins_count"] >= @parsed_response["leaderboard"][2]["wins_count"]
  end

  test "should get index with wrong start_date and end_date format" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { start_date: "miguel", end_date: "miguel" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["wins_count"] >= @parsed_response["leaderboard"][1]["wins_count"]
    assert @parsed_response["leaderboard"][1]["wins_count"] >= @parsed_response["leaderboard"][2]["wins_count"]
  end

  test "should get index with wrong category" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "miguel" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["wins_count"] >= @parsed_response["leaderboard"][1]["wins_count"]
    assert @parsed_response["leaderboard"][1]["wins_count"] >= @parsed_response["leaderboard"][2]["wins_count"]
  end

  test "should get index with wrong category params" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { categori: "total_likes", }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["wins_count"] >= @parsed_response["leaderboard"][1]["wins_count"]
    assert @parsed_response["leaderboard"][1]["wins_count"] >= @parsed_response["leaderboard"][2]["wins_count"]
  end

  test "should get index with wrong direction" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "wins_count", direction: "miguel" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["wins_count"] >= @parsed_response["leaderboard"][1]["wins_count"]
    assert @parsed_response["leaderboard"][1]["wins_count"] >= @parsed_response["leaderboard"][2]["wins_count"]
  end

  test "should get index with wrong category and direction" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "miguel", direction: "miguel" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["wins_count"] >= @parsed_response["leaderboard"][1]["wins_count"]
    assert @parsed_response["leaderboard"][1]["wins_count"] >= @parsed_response["leaderboard"][2]["wins_count"]
  end

  test "should get index with wrong category params and direction params" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { categori: "wins_count", directyon: "asc" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["wins_count"] >= @parsed_response["leaderboard"][1]["wins_count"]
    assert @parsed_response["leaderboard"][1]["wins_count"] >= @parsed_response["leaderboard"][2]["wins_count"]
  end

  test "should get index with wrong start_date params and end_date params" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { start_dateuh: "2024-01-01", end_dateeuh: Date.today.to_s }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal 3, @parsed_response["leaderboard"].count
    assert @parsed_response["leaderboard"][0]["wins_count"] >= @parsed_response["leaderboard"][1]["wins_count"]
    assert @parsed_response["leaderboard"][1]["wins_count"] >= @parsed_response["leaderboard"][2]["wins_count"]
  end

  test "should not get index if not authenticated" do
    sign_out @user

    assert_difference('User.count', 0) do
      get api_leaderboard_index_url
    end

    assert_response :unauthorized

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    assert_equal ["Invalid login credentials"], @parsed_response["errors"]["connection"]
  end
end