require 'test_helper'

class MicropostTest < ActiveSupport::TestCase
  def setup
    @user = users(:michael)
    @micropost = @user.microposts.build(content: 'Lorem ipsum')
  end

  test '正常系_有効なレコードか' do
    assert @micropost.valid?
  end

  test '正常系_レコードに紐づくユーザーが存在するか' do
    # 紐づくユーザーIDをnilにする
    @micropost.user_id = nil

    # 有効でないと判定されるか確認
    assert_not @micropost.valid?
  end

  test '正常系_テキストは空だとNG' do
    @micropost.content = ''
    assert_not @micropost.valid?
  end

  test '正常系_テキストは140文字以内でないとNG' do
    @micropost.content = 'a' * 141
    assert_not @micropost.valid?
  end
end
