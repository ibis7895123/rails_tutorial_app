class RelationshipsController < ApplicationController
  before_action :logged_in_user

  def create
    # 送られたfollowed_idからユーザーを検索
    @user = User.find(params[:followed_id])

    # ログインしているユーザーでフォローする
    current_user.follow(@user)

    # フォローしたユーザーの詳細へリダイレクト
    # レスポンスがHTMLのときのみ
    respond_to do |format|
      format.html { redirect_to user_path(@user) }
      format.js
    end
  end

  def destroy
    # リレーションからフォローしたユーザーを取得
    @user = Relationship.find(params[:id]).followed

    # ログインしているユーザーでフォロー解除する
    current_user.unfollow(@user)

    # フォローしたユーザーの詳細へリダイレクト
    # レスポンスがHTMLのときのみ
    respond_to do |format|
      format.html { redirect_to user_path(@user) }
      format.js
    end
  end
end
