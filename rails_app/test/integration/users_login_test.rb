require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  test 'login with invalid information' do
    # ログインページの表示チェック
    get login_path
    assert_template 'sessions/new'

    # 無効なデータをpostしてフラッシュメッセージの確認
    post login_path, params: { session: { email: '', password: '' } }
    assert_template 'sessions/new'
    assert_not flash.empty?

    # フラッシュメッセージが消えるのを確認
    get root_path
    assert flash.empty?
  end
end
