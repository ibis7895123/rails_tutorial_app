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
    assert is_logged_in_session_test?

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
    assert_not is_logged_in_session_test?

    # リダイレクト
    assert_redirected_to root_path
    follow_redirect!

    # 複数ウィンドウでログアウトクリックしたときにエラーにならないか
    delete logout_path
    follow_redirect!

    # ログインリンクがある
    assert_select 'a[href=?]', login_path

    # ログアウトリンクがない
    assert_select 'a[href=?]', logout_path, count: 0

    # ユーザー詳細へのリンクがない
    assert_select 'a[href=?]', user_path(@user), count: 0
  end

  test '正常系_ログイン_remember_me' do
    log_in_as_test(@user, remember_me: '1')

    # cookieにremember_tokenが保存されている
    assert_not_empty cookies['remember_token']

    # 保存されているremember_tokenがcontrollerのuserインスタンスと同じか
    assert_equal cookies['remember_token'], assigns(:user).remember_token
  end

  test '正常系_ログイン_remember_me_不使用' do
    # クッキーを保存してログイン
    log_in_as_test(@user, remember_me: '1')

    # ログアウト(クッキーは残る)
    delete logout_path

    # クッキーを削除してログイン
    log_in_as_test(@user, remember_me: '0')
    assert_empty cookies['remember_token']
  end
end
