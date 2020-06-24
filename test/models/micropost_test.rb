require 'test_helper'

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:michael)
    # このコードは慣習的に正しくない
    #@micropost = Micropost.new(content: "Lorem ipsum", user_id: @user.id)
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end

  test "should be valid" do
    assert @micropost.valid?
  end

  test "user id should be present" do
    @micropost.user_id = nil
    assert_not @micropost.valid?
  end

  test "content should be present" do
    @micropost.content = "   "
    assert_not @micropost.valid?
  end

  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    assert_not @micropost.valid?
  end

  test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end

  #マイクロポスト検索でヒットしないパターン
  test "Microposts search unhit" do
    keyword = ''
    search_result = Micropost.search(keyword)
    assert_equal search_result,nil
  end

  #マイクロポスト検索でヒットするパターン
  test "Microposts search hit" do
    keyword = 'orange'
    search_result = Micropost.search(keyword)
    #検索結果の内容が'I just ate an orange!'と一致していればOK
    search_result.each do |s|
      assert_equal 'I just ate an orange!',s.content
    end
  end

end
