require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end

  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar'
    assert_match @user.microposts.count.to_s, response.body
    assert_select 'div.pagination'
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end
  end

  #検索機能のテスト
  test "micropost search result" do

    #get user_path(@user), params: { microposts_keyword: "cats"}
    #assert_match micropost.content
    # microposts search (no result)
    get user_path(@user), params: { microposts_keyword: "abcdefghijk"}
    assert_equal "検索条件にヒットしませんでした。",flash[:info]
  end

end
