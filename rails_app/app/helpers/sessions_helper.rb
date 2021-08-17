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
      if !user || !user.authenticated?(:remember, cookies[:remember_token])
        return @current_user = nil
      end

      # ログイン(セッション情報を更新)
      log_in user
      return @current_user = user
    end

    # セッションにもcookieにも情報ない場合はnilを返す
    return @current_user = nil
  end

  # 渡されたユーザーがログイン済ユーザーと同じならtrue
  def current_user?(user)
    return user == current_user
  end

  # ログイン済ならtrue
  def logged_in?
    return !current_user.nil?
  end

  def forget(user)
    user.forget(current_user)
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  #  現在のユーザーをログアウトする
  def log_out
    # cookieを削除
    forget(current_user)

    # セッションを削除
    session.delete(:user_id)
  end

  # 記憶したURL(ない場合はデフォルト)にリダイレクト
  def redirect_back_or(default)
    redirect_url = session[:forwarding_url] ? session[:forwarding_url] : default
    redirect_to(redirect_url)

    # 使ったURLは削除しておく
    session.delete(:forwarding_url)
  end

  # アクセスしようとしたURLを覚えておく
  def store_location
    # 記憶するのはGETのみ
    session[:forwarding_url] = request.original_url if request.get?
  end
end
