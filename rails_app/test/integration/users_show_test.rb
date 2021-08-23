require 'test_helper'

class UsersShowTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @non_activated_user = users(:lana)
  end

  test '異常系_有効化されていないユーザーの詳細ページは見れない' do
    get user_path(@non_activated_user)

    # HOMEにリダイレクト
    assert_redirected_to root_path

    # エラーメッセージ
    assert_not flash[:danger].empty?
  end

  test '正常系_ユーザー詳細' do
    # ユーザー詳細を開く
    get user_path(@user)

    # タイトルなど要素のチェック
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    assert_select 'h1>img.gravatar'

    # 投稿数がページに表示されているか
    # 文字列に変換しないとマッチしない
    assert_match @user.microposts.count.to_s, response.body

    assert_select 'div.pagination'

    # 投稿内容が正しく表示されているか
    @user
      .microposts
      .paginate(page: 1)
      .each { |micropost| assert_match micropost.content, response.body }
  end
end
