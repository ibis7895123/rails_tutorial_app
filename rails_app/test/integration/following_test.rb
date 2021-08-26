require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    log_in_as_test(@user)
  end

  test '正常系_フォロー一覧ページ' do
    # フォロー一覧ページを開く
    get following_user_path(@user)

    # フォローが0でない
    assert_not @user.following.empty?

    # フォロー数が正しい
    assert_match @user.following.count.to_s, response.body

    # フォローしたユーザーのリンクがある
    @user.following.each do |followed|
      assert_select 'a[href=?]', user_path(followed)
    end
  end

  test '正常系_フォロワー一覧ページ' do
    # フォロワー一覧ページを開く
    get followers_user_path(@user)

    # フォロワーが0でない
    assert_not @user.followers.empty?

    # フォロー数が正しい
    assert_match @user.followers.count.to_s, response.body

    # フォローしたユーザーのリンクがある
    @user.followers.each do |follower|
      assert_select 'a[href=?]', user_path(follower)
    end
  end
end
