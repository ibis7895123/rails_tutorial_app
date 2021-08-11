class SessionsController < ApplicationController
  def new; end

  def create
    # emailからユーザーを探す
    email = params[:session][:email].downcase
    password = params[:session][:password]
    user = User.find_by(email: email)

    # ユーザーが見つからなかった or パスワードが間違ってたらエラーを返す
    if !user || !user.authenticate(password)
      flash[:danger] = 'Invalid email/password combination.'
      render 'new'
    end
  end

  def destroy; end
end
