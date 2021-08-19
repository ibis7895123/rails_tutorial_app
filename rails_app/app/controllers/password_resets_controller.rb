class PasswordResetsController < ApplicationController
  before_action :get_user, only: %i[edit update]
  before_action :valid_user, only: %i[edit update]

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

  # メールアドレスからユーザーを取得
  def get_user
    @user = User.find_by(email: params[:email])
  end
  private :get_user

  # 正しいユーザーかどうか確認する
  def valid_user
    # 1．ユーザーが存在する
    # 2．ユーザーが有効化済
    # 3．リセットトークンが正しい
    # 場合**以外**はHOMEに戻す
    unless @user && @user.activated? &&
             @user.authenticated?(:reset, params[:id])
      redirect_to root_path
    end
  end
end
