class PasswordResetsController < ApplicationController
  def new; end

  def create
    # メールアドレスからユーザーを特定
    @user = User.find_by(email: params[:password_reset][:email])

    # ユーザーが見つからない場合エラー
    if !@user
      flash.now[:danger] = 'Email address not found.'
      render 'new'
      return
    end

    # リセットダイジェストを発行
    @user.create_reset_digest

    # パスワードリセット用のメールを送信
    @user.send_password_reset_email

    flash[:info] = 'Email sent with password reset instructions.'
    redirect_to root_path
  end

  def edit; end
end
