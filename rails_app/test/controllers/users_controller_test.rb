require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
  end

  test 'should get new' do
    get signup_path
    assert_response :success
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
end
