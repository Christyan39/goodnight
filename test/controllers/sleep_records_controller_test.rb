require "test_helper"

class SleepRecordsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @sleep_record = sleep_records(:one)
  end

  test "should get index" do
    get sleep_records_url
    assert_response :success
  end

  test "should get new" do
    get new_sleep_record_url
    assert_response :success
  end

  test "should create sleep_record" do
    assert_difference("SleepRecord.count") do
      post sleep_records_url, params: { sleep_record: { clock_in: @sleep_record.clock_in, clock_out: @sleep_record.clock_out, duration: @sleep_record.duration } }
    end

    assert_redirected_to sleep_record_url(SleepRecord.last)
  end

  test "should show sleep_record" do
    get sleep_record_url(@sleep_record)
    assert_response :success
  end

  test "should get edit" do
    get edit_sleep_record_url(@sleep_record)
    assert_response :success
  end

  test "should update sleep_record" do
    patch sleep_record_url(@sleep_record), params: { sleep_record: { clock_in: @sleep_record.clock_in, clock_out: @sleep_record.clock_out, duration: @sleep_record.duration } }
    assert_redirected_to sleep_record_url(@sleep_record)
  end

  test "should destroy sleep_record" do
    assert_difference("SleepRecord.count", -1) do
      delete sleep_record_url(@sleep_record)
    end

    assert_redirected_to sleep_records_url
  end
end
