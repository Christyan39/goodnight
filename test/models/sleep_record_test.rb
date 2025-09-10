require "test_helper"

class SleepRecordTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  test "sleep_record is valid with valid attributes" do
    user = users(:one)
    sleep_record = SleepRecord.new(clock_in: Time.current, user: user, clock_out: Time.current + 1.hour, duration: 60)
    assert sleep_record.valid?
  end

  test "sleep_record belongs to user" do
    user = users(:one)
    sleep_record = SleepRecord.new(clock_in: Time.current, user: user, clock_out: Time.current + 1.hour, duration: 60)
    assert_equal user, sleep_record.user
  end
end
