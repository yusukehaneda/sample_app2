require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest

  def setup
    @user = users(:michael)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'
    # 無効な送信
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "" } }
    end
    assert_select 'div#error_explanation'
    assert_select 'div.alert-danger','1個のエラーがあります。'

    assert_select 'a[href=?]', '/?page=2'  # 正しいページネーションリンク
    # 有効な送信
    content = "This micropost really ties the room together"
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost: { content: content } }
      assert_equal  '投稿しました！',flash[:success]
    end
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body

    # 投稿を削除する

    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
      assert_equal '投稿が削除されました。',flash[:success]
    end
    # 違うユーザーのプロフィールにアクセス（削除リンクがないことを確認）
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end

  #検索機能のテスト
  test "micropost search result home" do
    log_in_as(@user)
    get root_path
    #get user_path(@user), params: { microposts_keyword: "cats"}
    #assert_match micropost.content
    # microposts search (no result)
    get root_path(@user), params: { keyword: "abcdefghijk"}
    assert_equal "検索条件にヒットしませんでした。",flash[:info]
  end
end
