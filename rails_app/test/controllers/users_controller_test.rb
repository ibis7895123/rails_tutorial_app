require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test '異常系_ログインしてない場合はユーザー一覧は見れない' do
    get users_path
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

  test '異常系_webページからのリクエストではadminフラグを変更できない' do
    # ログイン
    log_in_as_test(@other_user)

    # 管理者でないことを確認
    assert_not @other_user.admin?

    # ユーザーのadmin情報を更新するリクエストを送る
    patch user_path(@other_user), params: { user: { admin: true } }

    # 管理者フラグが変わってないことを確認
    assert_not @other_user.reload.admin?
  end

  test '異常系_ログインしてない場合はユーザーの削除できない' do
    # 削除リクエストを送ってもユーザー数が変化しないこと
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end

    # ログインページにリダイレクト
    assert_redirected_to login_path
  end

  test '異常系_管理者でないユーザー(ログイン済)はユーザーの削除できない' do
    # ログイン
    log_in_as_test(@other_user)

    # 削除リクエストを送ってもユーザー数が変化しないこと
    assert_no_difference 'User.count' do
      delete user_path(@user)
    end

    # HOMEにリダイレクト
    assert_redirected_to root_path
  end
end
