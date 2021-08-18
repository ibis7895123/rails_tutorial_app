require 'test_helper'

class UsersShowTest < ActionDispatch::IntegrationTest
  def setup
    @non_activated_user = users(:lana)
  end

  test '異常系_有効化されていないユーザーの詳細ページは見れない' do
    get user_path(@non_activated_user)

    # HOMEにリダイレクト
    assert_redirected_to root_path

    # エラーメッセージ
    assert_not flash[:danger].empty?
  end
end
