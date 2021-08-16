require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test '正常系_編集成功' do
    name = 'Foo Bar'
    email = 'foo@bar.com'

    # ログイン
    log_in_as_test(@user)

    # 編集ページを開く
    get edit_user_path(@user)
    assert_template 'users/edit'

    patch user_path(@user),
          params: {
            user: {
              name: name,
              email: email,
              password: '',
              password_confirmation: ''
            }
          }

    # フラッシュメッセージが入っているか
    assert_not flash.empty?

    # ユーザー詳細ページにリダイレクトされているか
    assert_redirected_to user_path(@user)

    # ユーザーをDBの値で更新
    @user.reload

    # データが更新されているか
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

  test '異常系_バリデーションエラー' do
    # ログイン
    log_in_as_test(@user)

    # 編集ページを開く
    get edit_user_path(@user)
    assert_template 'users/edit'

    patch user_path(@user),
          params: {
            user: {
              name: '',
              email: 'foo@invalid',
              password: 'foo',
              password_confirmation: 'bar'
            }
          }
    assert_template 'users/edit'
    assert_select 'div.alert', 'The form contains 4 errors.'
  end

  test '異常系_ログインせずに編集ページを開くとログインを促す' do
    # 編集ページを開く
    get edit_user_path(@user)

    # フラッシュメッセージが入っている
    assert_not flash.empty?

    # ログインページにリダイレクト
    assert_redirected_to login_path
  end

  test '異常系_ログインせずにユーザー情報更新するとログインを促す' do
    patch user_path(@user),
          params: {
            user: {
              name: @user.name,
              email: @user.email
            }
          }

    # フラッシュメッセージが入っている
    assert_not flash.empty?

    # ログインページにリダイレクト
    assert_redirected_to login_path
  end

  test '異常系_ログイン済のユーザーが自分以外の編集ページを見れない' do
    log_in_as_test(@other_user)
    get edit_user_path(@user)

    # フラッシュメッセージが入っていない
    assert flash.empty?

    # HOMEにリダイレクト
    assert_redirected_to root_path
  end

  test '異常系_ログイン済のユーザーが自分以外のユーザー情報を更新できない' do
    log_in_as_test(@other_user)
    patch user_path(@user),
          params: {
            user: {
              name: @user.name,
              email: @user.email
            }
          }

    # フラッシュメッセージが入っていない
    assert flash.empty?

    # HOMEにリダイレクト
    assert_redirected_to root_path
  end

  test '異常系_リダイレクトでログインしたあと、直前にいたページに戻す' do
    # 編集ページを開く
    get edit_user_path(@user)

    # ログイン
    log_in_as_test(@user)

    # 編集ページにリダイレクトされることを確認
    assert_redirected_to edit_user_path(@user)

    # 2回目ログイン
    log_in_as_test(@user)

    # 2回目はユーザー詳細ページにリダイレクトされることを確認
    assert_redirected_to user_path(@user)
  end
end
