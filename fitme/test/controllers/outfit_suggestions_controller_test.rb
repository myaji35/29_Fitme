require "test_helper"

class OutfitSuggestionsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get outfit_suggestions_index_url
    assert_response :success
  end

  test "should get show" do
    get outfit_suggestions_show_url
    assert_response :success
  end
end
