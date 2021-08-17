class SessionsController < ApplicationController
  def new; end

  def create
    # emailからユーザーを探す
    email = params[:session][:email].downcase
    password = params[:session][:password]
    @user = User.find_by(email: email)

    # ユーザーが見つからなかった or パスワードが間違ってたらエラーを返す
    if !@user || !@user.authenticate(password)
      flash.now[:danger] = 'Invalid email/password combination.'
      render 'new'
      return
    end

    # ユーザーが有効化されてなかったらエラーを返す
    if !@user.activated?
      message =
        'Account not activated. Check your email for the activation link.'

      flash[:warning] = message
      redirect_to root_path
      return
    end

    # ログイン
    log_in @user

    # remeber meにチェックを入れていればログイントークンを記憶する
    # チェックなしならログイントークンを削除
    params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)

    # ログイン前にいたページに戻す(デフォルトはユーザー詳細)
    redirect_back_or user_path(@user)
  end

  def destroy
    # ログイン済の場合のみログアウト
    log_out if logged_in?
    redirect_to root_path
  end
end
