class SessionsController < ApplicationController
  def new; end

  def create
    # emailからユーザーを探す
    email = params[:session][:email].downcase
    password = params[:session][:password]
    user = User.find_by(email: email)

    # ユーザーが見つからなかった or パスワードが間違ってたらエラーを返す
    if !user || !user.authenticate(password)
      flash.now[:danger] = 'Invalid email/password combination.'
      render 'new'
      return
    end

    # ログイン
    log_in user

    # ログイン情報を記憶する
    remember user

    redirect_to user_path(user)
  end

  def destroy
    log_out
    redirect_to root_path
  end
end
