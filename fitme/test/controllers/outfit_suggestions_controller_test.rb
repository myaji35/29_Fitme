require "test_helper"

class OutfitSuggestionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    sign_in @user
    @outfit_suggestion = outfit_suggestions(:one)
  end

  test "should get index" do
    get outfit_suggestions_url
    assert_response :success
  end

  test "should get show" do
    get outfit_suggestion_url(@outfit_suggestion)
    assert_response :success
  end
end
