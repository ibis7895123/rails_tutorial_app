class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  include SessionsHelper

  # ログイン済ユーザーかチェック
  # 未ログインならログインページへリダイレクト
  def logged_in_user
    # ログイン済なら何もしない
    return if logged_in?

    # ログイン後のリダイレクト先を記憶しておく
    store_location

    flash[:danger] = 'Please log in.'
    redirect_to login_path
  end
  private :logged_in_user
end
