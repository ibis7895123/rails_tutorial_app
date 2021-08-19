require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    # 送信メールのリセット
    ActionMailer::Base.deliveries.clear

    @user = users(:michael)
  end

  test '正常系_パスワードリセット' do
    # パスワードリセットページを開く
    get new_password_reset_path
    assert_template 'password_resets/new'

    # パスワードリセットのメールを送信
    post password_resets_path,
         params: {
           password_reset: {
             email: @user.email
           }
         }

    #  リセットダイジェストが更新されている
    assert_not_equal @user.reset_digest, @user.reload.reset_digest

    # メールが1通送信されている
    assert_equal ActionMailer::Base.deliveries.size, 1

    # フラッシュメッセージが入っている
    assert_not flash[:info].empty?

    # HOMEにリダイレクト
    assert_redirected_to root_path

    # パスワード再設定フォームを開く
    user = assigns[:user]
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'

    # hidden属性でemailを受け取っている
    assert_select 'input[name=email][type=hidden][value=?]', user.email

    # パスワード再設定リクエスト
    patch password_reset_path(user.reset_token),
          params: {
            email: user.email,
            user: {
              password: 'password',
              password_confirmation: 'password'
            }
          }

    # ログイン成功
    assert is_logged_in_session_test?

    # フラッシュメッセージが入っている
    assert_not flash[:success].empty?

    # ユーザー詳細にリダイレクト
    assert_redirected_to user_path(@user)

    # リセットダイジェストと日付がnilになっている
    @user.reload
    assert_nil @user.reset_digest
    assert_nil @user.reset_sent_at
  end

  test '異常系_パスワードリセット_メール送信時のメールアドレスが無効' do
    # パスワードリセットページを開く
    get new_password_reset_path

    # パスワードリセットのメールを送信(無効なメールアドレス)
    post password_resets_path, params: { password_reset: { email: '' } }

    # フラッシュメッセージにエラーが入っている
    assert_not flash[:danger].empty?

    # フォームページから進んでいない
    assert_template 'password_resets/new'
  end

  test '異常系_パスワードリセット_メールのリンク押下時にメールアドレスが無効' do
    # パスワードリセットページを開く
    get new_password_reset_path

    # パスワードリセットのメールを送信
    post password_resets_path,
         params: {
           password_reset: {
             email: @user.email
           }
         }

    # パスワード再設定フォームを開く(無効なメールアドレス)
    user = assigns[:user]
    get edit_password_reset_path(user.reset_token, email: '')

    # HOMEにリダイレクト
    assert_redirected_to root_path
  end

  test '異常系_パスワードリセット_無効なユーザー' do
    # パスワードリセットページを開く
    get new_password_reset_path

    # パスワードリセットのメールを送信
    post password_resets_path,
         params: {
           password_reset: {
             email: @user.email
           }
         }

    #  ユーザーを無効化しておく
    user = assigns[:user]
    user.toggle!(:activated)

    # パスワード再設定フォームを開く
    get edit_password_reset_path(user.reset_token, email: user.email)

    # フラッシュメッセージにエラーが入っている
    assert_not flash[:danger].empty?

    # HOMEにリダイレクト
    assert_redirected_to root_path
  end

  test '異常系_パスワードリセット_無効なパスワード' do
    # パスワードリセットページを開く
    get new_password_reset_path

    # パスワードリセットのメールを送信
    post password_resets_path,
         params: {
           password_reset: {
             email: @user.email
           }
         }

    # パスワード再設定フォームを開く
    user = assigns[:user]
    get edit_password_reset_path(user.reset_token, email: user.email)

    # パスワード再設定リクエスト(無効なパスワード)
    patch password_reset_path(user.reset_token),
          params: {
            email: user.email,
            user: {
              password: 'a',
              password_confirmation: 'bb'
            }
          }

    # バリデーションエラーが表示されている
    assert_select 'div#error_explanation'
  end

  test '異常系_パスワードリセット_パスワードが空' do
    # パスワードリセットページを開く
    get new_password_reset_path

    # パスワードリセットのメールを送信
    post password_resets_path,
         params: {
           password_reset: {
             email: @user.email
           }
         }

    # パスワード再設定フォームを開く
    user = assigns[:user]
    get edit_password_reset_path(user.reset_token, email: user.email)

    # パスワード再設定リクエスト(パスワードが空)
    patch password_reset_path(user.reset_token),
          params: {
            email: user.email,
            user: {
              password: '',
              password_confirmation: ''
            }
          }

    # バリデーションエラーが表示されている
    assert_select 'div#error_explanation'
  end

  test '異常系_パスワードリセット_トークンの期限切れ' do
    # パスワードリセットページを開く
    get new_password_reset_path

    # パスワードリセットのメールを送信
    post password_resets_path,
         params: {
           password_reset: {
             email: @user.email
           }
         }

    # パスワード再設定フォームを開く
    user = assigns[:user]
    get edit_password_reset_path(user.reset_token, email: user.email)

    # リセットトークンを有効期限切れにする
    user.update_attributes(reset_sent_at: 3.hours.ago)

    # パスワード再設定リクエスト
    patch password_reset_path(user.reset_token),
          params: {
            email: user.email,
            user: {
              password: 'password',
              password_confirmation: 'password'
            }
          }

    # パスワードリセットの最初にリダイレクトされる
    assert_redirected_to new_password_reset_path

    # リダイレクト先で「expired」の文字がページに表示されている
    follow_redirect!
    assert_match 'expired', response.body, response.body
  end
end
