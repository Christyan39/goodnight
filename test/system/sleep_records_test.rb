require "application_system_test_case"

class SleepRecordsTest < ApplicationSystemTestCase
  setup do
    @sleep_record = sleep_records(:one)
  end

  test "visiting the index" do
    visit sleep_records_url
    assert_selector "h1", text: "Sleep records"
  end

  test "should create sleep record" do
    visit sleep_records_url
    click_on "New sleep record"

    fill_in "Clock in", with: @sleep_record.clock_in
    fill_in "Clock out", with: @sleep_record.clock_out
    fill_in "Duration", with: @sleep_record.duration
    click_on "Create Sleep record"

    assert_text "Sleep record was successfully created"
    click_on "Back"
  end

  test "should update Sleep record" do
    visit sleep_record_url(@sleep_record)
    click_on "Edit this sleep record", match: :first

    fill_in "Clock in", with: @sleep_record.clock_in
    fill_in "Clock out", with: @sleep_record.clock_out
    fill_in "Duration", with: @sleep_record.duration
    click_on "Update Sleep record"

    assert_text "Sleep record was successfully updated"
    click_on "Back"
  end

  test "should destroy Sleep record" do
    visit sleep_record_url(@sleep_record)
    click_on "Destroy this sleep record", match: :first

    assert_text "Sleep record was successfully destroyed"
  end
end
