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

    expected_response = {
      "leaderboard" => [
        {"username" => "James Bond", "wins_count" => 1, "submissions_participation_rate" => 41.67, "contests_count" => 2, "likes_received_count" => 2, "winrate" => 50.0},
        {"username" => "Jane Doe", "wins_count" => 0, "submissions_participation_rate" => 0.0, "contests_count" => 0, "likes_received_count" => 0, "winrate" => 0.0},
        {"username" => "John Doe", "wins_count" => 0, "submissions_participation_rate" => 0.0, "contests_count" => 0, "likes_received_count" => 0, "winrate" => 0.0}
      ]
    }

    assert_equal expected_response, @parsed_response
  end

  test "should get index sort by wins asc" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "wins", direction: "asc" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    expected_response = {
      "leaderboard" => [
        {"username" => "Jane Doe", "wins_count" => 0, "submissions_participation_rate" => 0.0, "contests_count" => 0, "likes_received_count" => 0, "winrate" => 0.0},
        {"username" => "John Doe", "wins_count" => 0, "submissions_participation_rate" => 0.0, "contests_count" => 0, "likes_received_count" => 0, "winrate" => 0.0},
        {"username" => "James Bond", "wins_count" => 1, "submissions_participation_rate" => 41.67, "contests_count" => 2, "likes_received_count" => 2, "winrate" => 50.0}
      ]
    }

    assert_equal expected_response, @parsed_response
  end

  test "should get index sort by wins desc" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "wins", direction: "desc" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    expected_response = {
      "leaderboard" => [
        {"username" => "James Bond", "wins_count" => 1, "submissions_participation_rate" => 41.67, "contests_count" => 2, "likes_received_count" => 2, "winrate" => 50.0},
        {"username" => "Jane Doe", "wins_count" => 0, "submissions_participation_rate" => 0.0, "contests_count" => 0, "likes_received_count" => 0, "winrate" => 0.0},
        {"username" => "John Doe", "wins_count" => 0, "submissions_participation_rate" => 0.0, "contests_count" => 0, "likes_received_count" => 0, "winrate" => 0.0}
      ]
    }

    assert_equal expected_response, @parsed_response
  end

  test "should get index sort by submissions_participation_rate asc" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "submission_rate", direction: "asc" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    expected_response = {
      "leaderboard" => [
        {"username" => "Jane Doe", "wins_count" => 0, "submissions_participation_rate" => 0.0, "contests_count" => 0, "likes_received_count" => 0, "winrate" => 0.0},
        {"username" => "John Doe", "wins_count" => 0, "submissions_participation_rate" => 0.0, "contests_count" => 0, "likes_received_count" => 0, "winrate" => 0.0},
        {"username" => "James Bond", "wins_count" => 1, "submissions_participation_rate" => 41.67, "contests_count" => 2, "likes_received_count" => 2, "winrate" => 50.0}
      ]
    }

    assert_equal expected_response, @parsed_response
  end

  test "should get index sort by submissions_participation_rate desc" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "submission_rate", direction: "desc" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    expected_response = {
      "leaderboard" => [
        {"username" => "James Bond", "wins_count" => 1, "submissions_participation_rate" => 41.67, "contests_count" => 2, "likes_received_count" => 2, "winrate" => 50.0},
        {"username" => "Jane Doe", "wins_count" => 0, "submissions_participation_rate" => 0.0, "contests_count" => 0, "likes_received_count" => 0, "winrate" => 0.0},
        {"username" => "John Doe", "wins_count" => 0, "submissions_participation_rate" => 0.0, "contests_count" => 0, "likes_received_count" => 0, "winrate" => 0.0}
      ]
    }

    assert_equal expected_response, @parsed_response
  end

  test "should get index sort by contests_count asc" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "participations", direction: "asc" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    expected_response = {
      "leaderboard" => [
        {"username" => "Jane Doe", "wins_count" => 0, "submissions_participation_rate" => 0.0, "contests_count" => 0, "likes_received_count" => 0, "winrate" => 0.0},
        {"username" => "John Doe", "wins_count" => 0, "submissions_participation_rate" => 0.0, "contests_count" => 0, "likes_received_count" => 0, "winrate" => 0.0},
        {"username" => "James Bond", "wins_count" => 1, "submissions_participation_rate" => 41.67, "contests_count" => 2, "likes_received_count" => 2, "winrate" => 50.0}
      ]
    }

    assert_equal expected_response, @parsed_response
  end

  test "should get index sort by contests_count desc" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "participations", direction: "desc" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    expected_response = {
      "leaderboard" => [
        {"username" => "James Bond", "wins_count" => 1, "submissions_participation_rate" => 41.67, "contests_count" => 2, "likes_received_count" => 2, "winrate" => 50.0},
        {"username" => "Jane Doe", "wins_count" => 0, "submissions_participation_rate" => 0.0, "contests_count" => 0, "likes_received_count" => 0, "winrate" => 0.0},
        {"username" => "John Doe", "wins_count" => 0, "submissions_participation_rate" => 0.0, "contests_count" => 0, "likes_received_count" => 0, "winrate" => 0.0}
      ]
    }

    assert_equal expected_response, @parsed_response
  end

  test "should get index sort by likes_received_count asc" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "total_likes", direction: "asc" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    expected_response = {
      "leaderboard" => [
        {"username" => "Jane Doe", "wins_count" => 0, "submissions_participation_rate" => 0.0, "contests_count" => 0, "likes_received_count" => 0, "winrate" => 0.0},
        {"username" => "John Doe", "wins_count" => 0, "submissions_participation_rate" => 0.0, "contests_count" => 0, "likes_received_count" => 0, "winrate" => 0.0},
        {"username" => "James Bond", "wins_count" => 1, "submissions_participation_rate" => 41.67, "contests_count" => 2, "likes_received_count" => 2, "winrate" => 50.0}
      ]
    }

    assert_equal expected_response, @parsed_response
  end

  test "should get index sort by likes_received_count desc" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "total_likes", direction: "desc" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    expected_response = {
      "leaderboard" => [
        {"username" => "James Bond", "wins_count" => 1, "submissions_participation_rate" => 41.67, "contests_count" => 2, "likes_received_count" => 2, "winrate" => 50.0},
        {"username" => "Jane Doe", "wins_count" => 0, "submissions_participation_rate" => 0.0, "contests_count" => 0, "likes_received_count" => 0, "winrate" => 0.0},
        {"username" => "John Doe", "wins_count" => 0, "submissions_participation_rate" => 0.0, "contests_count" => 0, "likes_received_count" => 0, "winrate" => 0.0}
      ]
    }

    assert_equal expected_response, @parsed_response
  end

  test "should get index sort by winrate asc" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "winrate", direction: "asc" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    expected_response = {
      "leaderboard" => [
        {"username" => "Jane Doe", "wins_count" => 0, "submissions_participation_rate" => 0.0, "contests_count" => 0, "likes_received_count" => 0, "winrate" => 0.0},
        {"username" => "John Doe", "wins_count" => 0, "submissions_participation_rate" => 0.0, "contests_count" => 0, "likes_received_count" => 0, "winrate" => 0.0},
        {"username" => "James Bond", "wins_count" => 1, "submissions_participation_rate" => 41.67, "contests_count" => 2, "likes_received_count" => 2, "winrate" => 50.0}
      ]
    }

    assert_equal expected_response, @parsed_response
  end

  test "should get index sort by winrate desc" do
    assert_difference('User.count', 0) do
      get api_leaderboard_index_url, params: { category: "winrate", direction: "desc" }
    end

    assert_response :success

    assert_nothing_raised do
      @parsed_response = JSON.parse(response.body)
    end

    expected_response = {
      "leaderboard" => [
        {"username" => "James Bond", "wins_count" => 1, "submissions_participation_rate" => 41.67, "contests_count" => 2, "likes_received_count" => 2, "winrate" => 50.0},
        {"username" => "Jane Doe", "wins_count" => 0, "submissions_participation_rate" => 0.0, "contests_count" => 0, "likes_received_count" => 0, "winrate" => 0.0},
        {"username" => "John Doe", "wins_count" => 0, "submissions_participation_rate" => 0.0, "contests_count" => 0, "likes_received_count" => 0, "winrate" => 0.0}
      ]
    }

    assert_equal expected_response, @parsed_response
  end
end
