module SessionsHelper
  # 渡されたユーザーでログインする
  def log_in(user)
    session[:user_id] = user.id
  end

  # ユーザーのセッションを永続化する
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # ログインしているユーザーを返す
  def current_user
    # sessionにデータがあればそれを使う
    if user_id = session[:user_id]
      # idからユーザーを取得して返す
      # 2回目以降はキャッシュを返す
      return @current_user if !@current_user.nil?
      return @current_user = User.find_by(id: user_id)
    end

    # cookieにデータがある場合
    if user_id = cookies.signed[:user_id]
      user = User.find_by(id: user_id)

      # remember_tokenが正しくない場合nilを返す
      return nil if !user && !user.authenticated?(cookies[:remember_token])

      log_in user
      return @current_user = user
    end
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
