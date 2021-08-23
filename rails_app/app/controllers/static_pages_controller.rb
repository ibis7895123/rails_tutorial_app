class StaticPagesController < ApplicationController
  def home
    # ログインしていれば新規のmicropostを作成する
    @micropost = current_user.microposts.build if logged_in?
  end

  def help; end

  def about; end

  def contact; end
end
