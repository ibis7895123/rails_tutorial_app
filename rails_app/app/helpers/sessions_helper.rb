module SessionsHelper
  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  # ログインしているユーザーを返す
  def current_user
    # 未ログインならnilを返す
    return nil if !session[:user_id]

    # idからユーザーを取得して返す
    # 2回目以降はキャッシュを返す
    return @current_user if !@current_user.nil?

    return @current_user = User.find_by(id: session[:user_id])
  end

  # ログイン済ならtrue
  def logged_in?
    return !current_user.nil?
  end

  def log_out
    session.delete(:user_id)
    @current_user = nil
  end
end
