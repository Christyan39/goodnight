require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @token = JwtServices.encode({ user_id: @user.id })
    @auth_headers = { "Authorization" => "Bearer #{@token}" }
  end

  test "should get index with name filter and pagination" do
    # Create users to test search and pagination
    User.create!(name: "Alice")
    User.create!(name: "Bob")
    User.create!(name: "Charlie")

    # Test with name filter
    get users_url, params: { name: "A" }
    assert_response :success
    json = JSON.parse(@response.body)
    assert json["data"].any? { |u| u["name"].include?("A") }

    # Test with pagination
    get users_url, params: { name: "", limit: 2, page: 1 }
    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal 2, json["data"].size
    assert_equal 2, json["meta"]["per_page"].to_i
  end

  test "should show user" do
    get user_url(@user)
    assert_response :success
  end

  test "should show profile" do
    get profile_url, headers: @auth_headers
    assert_response :success
  end

  test "should login" do
    post login_url, params: { name: @user.name }
    assert_response :success
    json = JSON.parse(@response.body)
    assert json["token"].present?
    assert_equal @user.id, JwtServices.decode(json["token"])[:user_id]
  end

  test "should login failed" do
    post login_url, params: { name: "Invalid User" }
    assert_response :not_found
    json = JSON.parse(@response.body)
    assert json["error"].present?
  end

  test "should clock in" do
    post user_clock_in_url, headers: @auth_headers
    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal "Clock-in successful", json["message"]
    assert json["sleep_records"].present?
  end

  test "should not clock in if already clocked in" do
    # First clock in
    post user_clock_in_url, headers: @auth_headers
    assert_response :success

    # Try to clock in again without clocking out
    post user_clock_in_url, headers: @auth_headers
    assert_response :bad_request
    json = JSON.parse(@response.body)
    assert json["error"].present?
  end

  test "should clock out" do
    # First clock in
    post user_clock_in_url, headers: @auth_headers
    assert_response :success

    # Then clock out
    post user_clock_out_url, headers: @auth_headers
    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal "Clock-out successful", json["message"]
    assert json["sleep_records"].present?
  end
  
  test "should not clock out if not clocked in" do
    post user_clock_out_url, headers: @auth_headers
    assert_response :bad_request
    json = JSON.parse(@response.body)
    assert json["error"].present?
  end

  test "should follow and unfollow user" do
    other_user = users(:two)

    # Follow
    post user_follow_url, params: { following_user_id: other_user.id }, headers: @auth_headers
    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal "Follow successful", json["message"]

    # Unfollow
    post user_unfollow_url, params: { following_user_id: other_user.id }, headers: @auth_headers
    assert_response :success
    json = JSON.parse(@response.body)
    assert_equal "Unfollow successful", json["message"]
  end

  test "should not follow self or duplicate follow" do
    # Try to follow self
    post user_follow_url, params: { following_user_id: @user.id }, headers: @auth_headers
    assert_response :bad_request
    json = JSON.parse(@response.body)
    assert json["error"].present?

    # Try to follow the same user again
    other_user = users(:two)
    post user_follow_url, params: { following_user_id: other_user.id }, headers: @auth_headers
    assert_response :success

    post user_follow_url, params: { following_user_id: other_user.id }, headers: @auth_headers
    assert_response :bad_request
    json = JSON.parse(@response.body)
    assert json["error"].present?
  end 

  test "should not unfollow self or non-followed user or following user not exist or current user not exist" do
    # Try to unfollow self
    post user_unfollow_url, params: { following_user_id: @user.id }, headers: @auth_headers
    assert_response :bad_request
    json = JSON.parse(@response.body)
    assert json["error"].present?

    # Try to unfollow a user not being followed
    other_user = users(:two)
    post user_unfollow_url, params: { following_user_id: other_user.id }, headers: @auth_headers
    assert_response :bad_request
    json = JSON.parse(@response.body)
    assert json["error"].present?

    # Try to unfollow a non-existing user
    post user_unfollow_url, params: { following_user_id: 9999 }, headers: @auth_headers
    assert_response :not_found
    json = JSON.parse(@response.body)
    assert json["error"].present?

    #try to unfollow when current user does not exist (invalid token)
    invalid_token = JwtServices.encode({ user_id: -1 })
    invalid_auth_headers = { "Authorization" => "Bearer #{invalid_token}" }
    post user_unfollow_url, params: { following_user_id: @user.id }, headers: invalid_auth_headers
    assert_response :internal_server_error
    json = JSON.parse(@response.body)
    assert json["error"].present?
  end

  test "should return not found for missing user" do
    get user_url(id: -1) # Use an ID that does not exist
    assert_response :not_found
    assert_includes @response.body, "User not found"
  end

  test "should get sleep records with pagination" do
    get user_sleep_records_url, headers: @auth_headers, params: { page: 1, limit: 10 }
    assert_response :success
    json = JSON.parse(@response.body)
    assert json["sleep_records"].present?
    assert json["meta"].present?

    #try without pagination params
    get user_sleep_records_url, headers: @auth_headers
    assert_response :success
    json = JSON.parse(@response.body)
    assert json["sleep_records"].present?
    assert json["meta"].present?
  end

  test "should get following sleep records with pagination" do
    # First, make the user follow another user who has sleep records
    other_user = users(:two)
    @user.followings.create!(following_user_id: other_user.id)
    other_user.sleep_records.create!(clock_in: 2.hours.ago, clock_out: 1.hour.ago)

    get user_following_sleep_records_url, headers: @auth_headers, params: { page: 1, limit: 10 }
    assert_response :success
    json = JSON.parse(@response.body)
    assert json["sleep_records"].present?
    assert json["meta"].present?

    #try without pagination params
    get user_following_sleep_records_url, headers: @auth_headers
    assert_response :success
    json = JSON.parse(@response.body)
    assert json["sleep_records"].present?
    assert json["meta"].present?
  end
end
