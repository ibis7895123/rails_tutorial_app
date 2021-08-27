require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user =
      User.new(
        name: 'Example User',
        email: 'user@example.com',
        password: 'password',
        password_confirmation: 'password'
      )
  end

  test '正常系_有効なユーザー' do
    assert @user.valid?
  end

  test '異常系_名前は空文字NG' do
    @user.name = '   '
    assert_not @user.valid?
  end

  test '異常系_メールアドレスは空文字NG' do
    @user.email = '   '
    assert_not @user.valid?
  end

  test '異常系_名前が長すぎる' do
    @user.name = 'a' * 51
    assert_not @user.valid?
  end

  test '異常系_メールアドレスが長すぎる' do
    @user.name = 'a' * 244 << 'example.com'
    assert_not @user.valid?
  end

  test '正常系_有効なメールアドレスチェック' do
    valid_addresses = %w[
      user@example.com
      USER@foo.COM
      A_US-ER@foo.bar.org
      first.last@foo.jp
      alice+bob@baz.cn
    ]

    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  test '異常系_無効なメールアドレスチェック' do
    invalid_addresses = %w[
      user@example,com
      user_at_foo.org
      user.name@example.
      foo@bar_baz.com
      foo@bar+baz.com
    ]

    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test '異常系_重複したメールアドレスは登録できない' do
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    @user.save
    assert_not duplicate_user.valid?
  end

  test '正常系_メールアドレスは小文字で登録される' do
    mixed_case_email = 'Foo@ExAMPle.CoM'
    @user.email = mixed_case_email
    @user.save
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  test '異常系_パスワードは空文字NG' do
    @user.password = @user.password_confirmation = ' ' * 6
    assert_not @user.valid?
  end

  test '異常系_パスワードが短すぎる' do
    @user.password = @user.password_confirmation = 'a' * 5
    assert_not @user.valid?
  end

  test '正常系_remember_digestが空文字で認証状態を確認してもエラーにならない' do
    assert_not @user.authenticated?(:remember, '')
  end

  # micropostsのテスト
  test '正常系_ユーザーを削除したときに投稿内容も削除される' do
    # 一度saveしないとcreateがエラーになるので保存
    @user.save

    # 投稿を作成
    @user.microposts.create!(content: 'Lorem ipsum')

    # ユーザーを削除したときに投稿数が1減っているか
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end

  # フォロー関連のテスト
  test '正常系_ユーザーのフォロー、アンフォロー' do
    michael = users(:michael)
    archer = users(:archer)

    # michaelはarcherをフォローしていない
    assert_not michael.following?(archer)

    # フォロー
    michael.follow(archer)

    # フォロー状態になる
    assert michael.following?(archer)

    # archerから見たときはフォロワーにmichaelが追加されている
    assert archer.followers.include?(michael)

    # アンフォロー
    michael.unfollow(archer)

    # フォローしていない
    assert_not michael.following?(archer)
  end

  test '正常系_投稿のフィード' do
    # michael と lanaは相互フォロー
    # archer は michael をフォローしている前提
    michael = users(:michael)
    archer = users(:archer)
    lana = users(:lana)

    # フォローしているユーザーの投稿が見れる
    lana.microposts.each do |post_followed|
      assert michael.feed.include?(post_followed)
    end

    # 自分自身の投稿が見れる
    michael.microposts.each do |post_self|
      assert michael.feed.include?(post_self)
    end

    # フォローしていないユーザーの投稿は見れない
    archer.microposts.each do |post_unfollowed|
      assert_not michael.feed.include?(post_unfollowed)
    end
  end
end
