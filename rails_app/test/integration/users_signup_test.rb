require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
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

  test '正常系_アカウント登録' do
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
    follow_redirect! # リダイレクト
    assert_template 'users/show'
    assert_not flash[:success].empty?

    # セッションにユーザーIDがある
    assert is_logged_in_session_test?
  end
end
