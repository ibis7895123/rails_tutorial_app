require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
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

  test '正常系_ユーザーをフォロー_web' do
    # フォローしたあとにフォロー数が1増えている
    assert_difference '@user.following.count', 1 do
      post relationships_path, params: { followed_id: @other_user.id }
    end
  end

  test '正常系_ユーザーをフォロー_ajax' do
    # フォローしたあとにフォロー数が1増えている
    assert_difference '@user.following.count', 1 do
      post relationships_path,
           xhr: true,
           params: {
             followed_id: @other_user.id
           }
    end
  end

  test '正常系_ユーザーをフォロー解除_web' do
    # ユーザーをフォロー
    @user.follow(@other_user)

    relationship =
      @user.active_relationships.find_by(followed_id: @other_user.id)

    # フォロー解除したあとにフォロー数が1減っている
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship)
    end
  end

  test '正常系_ユーザーをフォロー解除_ajax' do
    # ユーザーをフォロー
    @user.follow(@other_user)

    relationship =
      @user.active_relationships.find_by(followed_id: @other_user.id)

    # フォロー解除したあとにフォロー数が1減っている
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship), xhr: true
    end
  end
end
