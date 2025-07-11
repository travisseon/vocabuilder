require "test_helper"

class SentencesControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get sentences_show_url
    assert_response :success
  end

  test "should get check_answer" do
    get sentences_check_answer_url
    assert_response :success
  end

  test "should get complete" do
    get sentences_complete_url
    assert_response :success
  end
end
