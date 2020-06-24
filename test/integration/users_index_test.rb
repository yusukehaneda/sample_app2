require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest

  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
  end

  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    first_page_of_users = User.paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      #ユーザー一覧のadmin以外の人にはdeleteリンクがあるはず
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
      assert_equal flash[:success],'ユーザーが削除されました。'
    end
  end

  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
     # adminじゃないからdeleteという文字はindexページにゼロである
    assert_select 'a', text: 'delete', count: 0
  end

  test "user search result" do
    log_in_as(@admin)

    # User search (no result)
    get users_path, params: { users_keyword: "abcdefghijk"}
    assert_equal "検索条件にヒットしませんでした。",flash[:info]
  end
end
