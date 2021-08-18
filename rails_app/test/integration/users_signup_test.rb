require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  def setup
    # メールの配信ボックスを初期化(他のメールを使ったテストと干渉しないように)
    ActionMailer::Base.deliveries.clear
  end

  test '異常系_アカウント登録_バリデーションエラー' do
    get signup_path

    # post前後で「User.count」の値が変化していないことをチェック
    assert_no_difference 'User.count' do
      post signup_path,
           params: {
             user: {
               name: '',
               email: 'user@invalid',
               password: 'foo',
               password_confirmation: 'bar'
             }
           }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'
    assert_select 'div.field_with_errors'
    assert_select 'form[action="/signup"]'
  end

  test '正常系_アカウント登録&アカウント有効化' do
    get signup_path

    # ユーザー作成したあとにUser.countが1増えているか
    assert_difference 'User.count', 1 do
      post signup_path,
           params: {
             user: {
               name: 'Example User',
               email: 'user@example.com',
               password: 'password',
               password_confirmation: 'password'
             }
           }
    end

    # メール送信が1件されたことを確認
    assert_equal 1, ActionMailer::Base.deliveries.size

    # この時点ではアカウントは有効化していない
    user = assigns(:user)
    assert_not user.activated?

    # 有効化リクエスト
    get edit_account_activation_path(user.activation_token, email: user.email)

    # アカウントが有効化された
    assert user.reload.activated?

    follow_redirect! # リダイレクト

    assert_template 'users/show'
    assert_not flash[:success].empty?

    # セッションにユーザーIDがある
    assert is_logged_in_session_test?
  end

  test '異常系_アカウント登録&アカウント有効化_有効化前はログインできない' do
    get signup_path

    # ユーザー作成したあとにUser.countが1増えているか
    assert_difference 'User.count', 1 do
      post signup_path,
           params: {
             user: {
               name: 'Example User',
               email: 'user@example.com',
               password: 'password',
               password_confirmation: 'password'
             }
           }
    end

    # 有効化していない状態ではログインできない
    user = assigns(:user)
    log_in_as_test(user)
    assert_not is_logged_in_session_test?
  end

  test '異常系_アカウント登録&アカウント有効化_トークンが不正' do
    get signup_path

    # ユーザー作成したあとにUser.countが1増えているか
    assert_difference 'User.count', 1 do
      post signup_path,
           params: {
             user: {
               name: 'Example User',
               email: 'user@example.com',
               password: 'password',
               password_confirmation: 'password'
             }
           }
    end

    # 不正なトークンで有効化リクエスト
    user = assigns(:user)
    get edit_account_activation_path('invalid token', email: user.email)

    # HOMEにリダイレクトされる
    assert_redirected_to root_path

    # ログインできてない
    assert_not is_logged_in_session_test?

    # フラッシュメッセージにエラーが入っている
    assert_not flash[:danger].empty?
  end

  test '異常系_アカウント登録&アカウント有効化_メールアドレスが不正' do
    get signup_path

    # ユーザー作成したあとにUser.countが1増えているか
    assert_difference 'User.count', 1 do
      post signup_path,
           params: {
             user: {
               name: 'Example User',
               email: 'user@example.com',
               password: 'password',
               password_confirmation: 'password'
             }
           }
    end

    # 不正なメールアドレスで有効化リクエスト
    user = assigns(:user)
    get edit_account_activation_path(user.activation_token, email: 'invalid')

    # HOMEにリダイレクトされる
    assert_redirected_to root_path

    # ログインできてない
    assert_not is_logged_in_session_test?

    # フラッシュメッセージにエラーが入っている
    assert_not flash[:danger].empty?
  end
end
