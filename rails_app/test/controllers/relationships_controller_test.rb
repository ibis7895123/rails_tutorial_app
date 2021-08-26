require 'test_helper'

class RelationshipsControllerTest < ActionDispatch::IntegrationTest
  test '異常系_ログインしていないとフォローはできない' do
    assert_no_difference 'Relationship.count' do
      post relationships_path
    end

    # 未ログインの場合、ログインページへリダイレクト
    assert_redirected_to login_path
  end

  test '異常系_ログインしていないとフォロー解除はできない' do
    assert_no_difference 'Relationship.count' do
      delete relationship_path(relationships(:one))
    end

    # 未ログインの場合、ログインページへリダイレクト
    assert_redirected_to login_path
  end
end
