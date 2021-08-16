require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test '正常系_ログインしてない場合はユーザー一覧は見れない' do
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

  test '正常系_webページからのリクエストではadminフラグを変更できない' do
    # ログイン
    log_in_as_test(@other_user)

    # 管理者でないことを確認
    assert_not @other_user.admin?

    # ユーザーのadmin情報を更新するリクエストを送る
    patch user_path(@other_user), params: { user: { admin: true } }

    # 管理者フラグが変わってないことを確認
    assert_not @other_user.reload.admin?
  end
end
