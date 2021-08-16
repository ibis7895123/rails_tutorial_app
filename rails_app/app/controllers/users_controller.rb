class UsersController < ApplicationController
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
end
