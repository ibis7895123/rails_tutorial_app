require 'test_helper'

class RelationshipTest < ActiveSupport::TestCase
  def setup
    @relationship =
      Relationship.new(
        follower_id: users(:michael).id,
        followed_id: users(:archer).id
      )
  end

  test '正常系_有効なデータ' do
    assert @relationship.valid?
  end

  test '異常系_フォロワーIDは必須' do
    @relationship.follower_id = nil
    assert_not @relationship.valid?
  end

  test '異常系_フォロードIDは必須' do
    @relationship.followed_id = nil
    assert_not @relationship.valid?
  end
end
