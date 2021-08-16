require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test 'ページネーション付きで一覧ページを取得' do
    # ログイン
    log_in_as_test(@user)

    # 一覧ページを開く(ページは1)
    get users_path

    assert_template 'users/index'

    # ページャーがある(上下)
    assert_select 'div.pagination', count: 2

    # 表示されているユーザーのリンクが正しい
    User
      .paginate(page: 1)
      .each do |user|
        assert_select 'a[href=?]', user_path(user), text: user.name
      end
  end
end
