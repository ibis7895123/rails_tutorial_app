require 'test_helper'

class SessionsHelperTest < ActionView::TestCase
  def setup
    @user = users(:michael)

    # セッションを永続化
    remember(@user)
  end

  test '正常系_セッションがnilのときに正しいユーザーを返す' do
    assert_equal @user, current_user

    # current_userを呼ぶとセッションにデータが保存されることを確認
    assert is_logged_in_session_test?
  end

  test '異常系_rememberトークンが間違っている場合にユーザーがnilになる' do
    # DBのremember_digestを更新
    @user.update_attribute(:remember_digest, User.digest(User.new_token))

    assert_nil current_user
  end
end
