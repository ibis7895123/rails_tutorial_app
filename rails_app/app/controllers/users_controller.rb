class UsersController < ApplicationController
  # ページ表示前の処理
  before_action :logged_in_user, only: %i[index edit update]
  before_action :correct_user, only: %i[edit update]

  def index
    @users = User.all
  end

  def show
    @user = User.find(params[:id])
    # 以下を埋め込むとコンソールでその時点のデバッグができる
    # debugger
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    # 保存が成功したかどうかで遷移先を分岐
    if @user.save
      # 自動でログインしておく
      log_in @user

      flash[:success] = 'Welcome to the Sample App!'

      # ユーザー詳細へリダイレクト
      redirect_to user_path(@user)
    else
      render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])

    if @user.update_attributes(user_params)
      # 更新に成功
      flash[:success] = 'Profile updated.'
      redirect_to user_path(@user)
      return
    end

    # 更新に失敗
    render 'edit'
  end

  def user_params
    params
      .require(:user)
      .permit(:name, :email, :password, :password_confirmation)
  end

  private :user_params

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

  def correct_user
    @user = User.find(params[:id])

    # 自分以外のページを開こうとしていたらHOMEに戻す
    redirect_to root_path unless current_user?(@user)
  end

  private :logged_in_user
end
