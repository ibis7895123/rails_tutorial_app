require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test '異常系_ログイン_バリデーションエラー' do
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

  test '正常系_ログイン' do
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

  test '正常系_ログアウト' do
    # ログイン
    get login_path
    post login_path,
         params: {
           session: {
             email: @user.email,
             password: 'password'
           }
         }

    #  セッションにユーザーIDがあるか
    assert is_logged_in_session?

    # リダイレクト
    assert_redirected_to user_path(@user)
    follow_redirect!

    assert_template 'users/show'

    # ログインリンクがない
    assert_select 'a[href=?]', login_path, count: 0

    # ログアウトリンクがある
    assert_select 'a[href=?]', logout_path

    # ユーザー詳細へのリンクがある
    assert_select 'a[href=?]', user_path(@user)

    # ログアウト
    delete logout_path

    # セッションからユーザーIDが消えているか
    assert_not is_logged_in_session?

    # リダイレクト
    assert_redirected_to root_path
    follow_redirect!

    # ログインリンクがある
    assert_select 'a[href=?]', login_path

    # ログアウトリンクがない
    assert_select 'a[href=?]', logout_path, count: 0

    # ユーザー詳細へのリンクがない
    assert_select 'a[href=?]', user_path(@user), count: 0
  end
end
