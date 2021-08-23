require 'test_helper'

class MicropostsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @micropost = microposts(:orange)
  end

  test '異常系_ログイン状態でないと投稿作成できない' do
    # ログインせずに投稿を作成した前後でpostの数が変わってない
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: 'Lorem ipsum' } }
    end

    # ログインページにリダイレクト
    assert_redirected_to login_path
  end

  test '異常系_ログイン状態でないと投稿を削除できない' do
    # ログインせずに投稿を削除した前後でpostの数が変わってない
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost)
    end

    # ログインページにリダイレクト
    assert_redirected_to login_path
  end
end
