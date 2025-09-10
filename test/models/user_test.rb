require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "user is valid with valid attributes" do
    user = User.new(name: "Test User")
    assert user.valid?
  end

  test "user has many followings" do
    user = User.create!(name: "Test User")
    following = User.create!(name: "Following User")
    user.followings.create!(following_user_id: following.id)
    assert_equal 1, user.followings.count
  end

  test "user has many followers" do
    user = User.create!(name: "Test User")
    follower = User.create!(name: "Follower User")
    follower.followings.create!(following_user_id: user.id)
    assert_equal 1, user.followers.count
  end

  test "user has many sleep_records" do
    user = User.create!(name: "Test User")
    user.sleep_records.create!(clock_in: Time.current)
    assert_equal 1, user.sleep_records.count
  end
end
