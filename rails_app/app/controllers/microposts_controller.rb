class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i[create destroy]
  before_action :correct_user, only: %i[destroy]

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

  def destroy
    @micropost.destroy
    flash[:success] = 'Micropost deleted!'

    # 戻る先がある場合はそこに戻る(デフォルトはHOME)
    redirect_back(fallback_location: root_path)
  end

  # 許可されたパラメータのみ取得する
  def micropost_params
    params.require(:micropost).permit(:content)
  end
  private :micropost_params

  def correct_user
    @micropost = current_user.microposts.find_by(id: params[:id])

    flash[:danger] = "You can't delete someone else's micropost."

    # 該当の投稿が見つからなければHOMEへ
    redirect_to root_path if @micropost.nil?
  end
end
