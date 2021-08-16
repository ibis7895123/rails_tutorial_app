require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test '正常系_編集成功' do
    name = 'Foo Bar'
    email = 'foo@bar.com'

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
end
