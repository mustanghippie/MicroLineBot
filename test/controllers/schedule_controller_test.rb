require 'test_helper'

class ScheduleControllerTest < ActionDispatch::IntegrationTest
  test "should get ping" do
    get schedule_ping_url
    assert_response :success
  end

end
