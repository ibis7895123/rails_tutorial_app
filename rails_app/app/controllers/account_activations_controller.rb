class AccountActivationsController < ApplicationController
  def edit
    # メールアドレスからユーザーを特定
    user = User.find_by(email: params[:email])

    # 1．ユーザーが見つからない
    # 2．ユーザーが有効化済み
    # 3．トークンの認証に失敗
    # した場合はエラー文を出してHOMEに戻す
    if !user || user.activated? ||
         !user.authenticated?(:activation, params[:id])
      flash[:danger] = 'Invalid activation link.'
      redirect_to root_path
      return
    end

    # アカウントを有効化する
    user.activate

    # ログイン
    log_in user

    flash[:success] = 'Account activated!'
    redirect_to user_path(user)
  end
end
