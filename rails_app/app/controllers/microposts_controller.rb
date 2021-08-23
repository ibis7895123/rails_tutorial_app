class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i[create destroy]

  def create
    # 投稿の作成
    @micropost = current_user.microposts.build(micropost_params)

    # 投稿の保存
    is_post_success = @micropost.save

    # 保存に失敗したらHOMEに戻す
    if !is_post_success
      @feed_items = []
      render 'static_pages/home'
      return
    end

    flash[:success] = 'Micropost created!'
    redirect_to root_path
  end

  def destroy; end

  # 許可されたパラメータのみ取得する
  def micropost_params
    params.require(:micropost).permit(:content)
  end
  private :micropost_params
end
