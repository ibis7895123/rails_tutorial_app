class PasswordResetsController < ApplicationController
  before_action :get_user, only: %i[edit update]
  before_action :valid_user, only: %i[edit update]
  before_action :check_expiration, only: %i[edit update]

  def new; end

  def create
    # メールアドレスからユーザーを特定
    @user = User.find_by(email: params[:password_reset][:email].downcase)

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

  def update
    # 入力パスワードが空の場合、エラー
    # ユーザー編集ではpasswordが空でもOKなので、ここで個別にエラー検知する
    if params[:user][:password].empty?
      @user.errors.add(:password, :blank)
      render 'edit'
      return
    end

    # パスワードの更新
    is_update_success = @user.update_attributes(user_params)

    # 更新に失敗した場合、エラー
    if !is_update_success
      render 'edit'
      return
    end

    # ログイン
    log_in @user

    # リセットダイジェストとリセット日時をnilにする
    @user.update_attributes(reset_digest: nil, reset_sent_at: nil)

    flash[:success] = 'Password has been reset.'
    redirect_to user_path(@user)
  end

  # 許可されたパラメータのみ取得する
  def user_params
    return params.require(:user).permit(:password, :password_confirmation)
  end
  private :user_params

  # メールアドレスからユーザーを取得
  def get_user
    return @user = User.find_by(email: params[:email])
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
      flash[:danger] = 'This user is invalid.'
      redirect_to root_path
    end
  end
  private :valid_user

  # パスワードリセットトークンが期限切れかどうか確認する
  def check_expiration
    # 期限内なら何もしない
    return if !@user.password_reset_expired?

    # 期限切れならエラーを出して、リセット処理の最初に戻す
    flash[:danger] = 'Password reset has expired.'
    redirect_to new_password_reset_path
  end
  private :check_expiration
end
