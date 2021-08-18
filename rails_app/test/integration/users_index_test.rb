require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin_user = users(:michael)
    @non_admin_user = users(:archer)
    @non_activated_user = users(:lana)
  end

  test '正常系_ページネーション付きで一覧ページを取得_管理者ユーザー' do
    # ログイン
    log_in_as_test(@admin_user)

    # 一覧ページを開く(ページは1)
    get users_path

    assert_template 'users/index'

    # ページャーがある(上下)
    assert_select 'div.pagination', count: 2

    User
      .where(activated: true)
      .paginate(page: 1)
      .each do |user|
        # 表示されているユーザーのリンクが正しい
        assert_select 'a[href=?]', user_path(user), text: user.name

        # 自分以外のユーザーには削除リンクが表示される
        if user != @admin_user
          assert_select 'a[href=?]', user_path(user), text: 'delete'
        end
      end

    # 有効化されていないユーザーは表示されない
    assert_select 'a[href=?]',
                  user_path(@non_activated_user),
                  text: @non_activated_user.name,
                  count: 0

    # non_admin_userを削除したあと、ユーザー数が減っている
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin_user)
    end
  end

  test '正常系_ページネーション付きで一覧ページを取得_一般ユーザー' do
    # ログイン
    log_in_as_test(@non_admin_user)

    # 一覧ページを開く
    get users_path

    # 削除リンクが表示されない
    assert_select 'a', text: 'delete', count: 0
  end
end
