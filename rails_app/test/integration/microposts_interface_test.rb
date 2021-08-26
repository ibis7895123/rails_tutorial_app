require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test '正常系_投稿の新規作成' do
    # ログイン
    log_in_as_test(@user)

    # HOMEを開く
    get root_path

    # フォローの統計情報が表示されている
    assert_select "strong#followers", text: @user.followers.count.to_s
    assert_select "strong#following", text: @user.following.count.to_s

    # ページネーションがある(投稿が表示されている)
    assert_select 'div.pagination'

    # ファイルアップロードがある
    assert_select 'input[type=file]'

    # fixtureフォルダのファイルをアップロード
    picture = fixture_file_upload('test/fixtures/files/rails.png', 'image/png')
    content = 'This micropost really ties the room together'

    # 投稿したあとに投稿数が1増えていることを確認
    assert_difference 'Micropost.count', 1 do
      post microposts_path,
           params: {
             micropost: {
               content: content,
               picture: picture
             }
           }
    end

    # HOMEにリダイレクト
    assert_redirected_to root_path

    # 投稿内容がHOMEに表示されている
    follow_redirect!
    assert_match content, response.body
  end

  test '異常系_空投稿はNG' do
    # ログイン
    log_in_as_test(@user)

    # HOMEを開く
    get root_path

    # 投稿しても投稿数が変わってないことを確認
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: '' } }
    end

    # バリデーションエラーの内容が表示されている
    assert_select 'div#error_explanation'
  end

  test '正常系_投稿の削除' do
    # ログイン
    log_in_as_test(@user)

    # HOMEを開く
    get root_path

    # deleteボタンが表示されている
    assert_select 'a', text: 'delete'

    first_micropost = @user.microposts.paginate(page: 1).first

    # 削除したあと投稿数が1減っている
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end

    # 削除した投稿内容がマッチしない
    follow_redirect!
    assert_no_match first_micropost.content, response.body
  end

  test '異常系_違うユーザーのプロフィールでは削除できない' do
    # ログイン
    log_in_as_test(@user)

    # 別のユーザー詳細を開く
    get user_path(users(:archer))

    # deleteボタンが表示されていない
    assert_select 'a', text: 'delete', count: 0
  end

  test '正常系_サイドバーの投稿数が正しい' do
    # ログイン
    log_in_as_test(@user)

    # HOMEを開く
    get root_path

    # 投稿数が正しいか
    assert_match "#{@user.microposts.count} microposts", response.body

    # 別ユーザーでログイン、HOMEを開く
    other_user = users(:malory)
    log_in_as_test(other_user)
    get root_path

    # 投稿数が0
    assert_match '0 microposts', response.body

    # 投稿を1件作成
    other_user.microposts.create!(content: 'test micropost')

    # 投稿数のテキストが更新されている
    get root_path
    assert_match '1 micropost', response.body
  end
end
