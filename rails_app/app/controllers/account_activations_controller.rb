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

    # 有効化フラグをONにして日付を記録
    user.update_attribute(:activated, true)
    user.update_attribute(:activated_at, Time.zone.now)

    # ログイン
    log_in user

    flash[:success] = 'Account activated!'
    redirect_to user_path(user)
  end
end
