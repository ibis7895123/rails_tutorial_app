require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

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

  test 'login with valid information' do
    # ログイン
    get login_path
    post login_path,
         params: {
           session: {
             email: @user.email,
             password: 'password'
           }
         }

    # ログインが成功してユーザー詳細へリダイレクト
    assert_redirected_to user_path(@user)
    follow_redirect!

    assert_template 'users/show'

    # ログインリンクがない
    assert_select 'a[href=?]', login_path, count: 0

    # ログアウトリンクがある
    assert_select 'a[href=?]', logout_path

    # ユーザー詳細へのリンクがある
    assert_select 'a[href=?]', user_path(@user)
  end
end
