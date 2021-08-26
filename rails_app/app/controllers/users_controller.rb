class UsersController < ApplicationController
  # ページ表示前の処理
  before_action :logged_in_user, only: %i[index edit update destroy following followers]
  before_action :correct_user, only: %i[edit update]
  before_action :admin_user, only: :destroy

  def index
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])

    # 有効なユーザーでない場合はHOMEに戻す
    if !@user.activated?
      flash[:danger] = 'This user is not activated.'
      redirect_to root_path
      return
    end

    # 紐づく投稿を取得
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    # 保存が成功したかどうかで遷移先を分岐
    if @user.save
      # アカウントの有効化メールを送信
      @user.send_activation_email

      flash[:info] = 'Please check your email to activate your account.'
      redirect_to root_path
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

  def destroy
    # DBから該当のユーザーを削除
    User.find(params[:id]).destroy

    flash[:success] = 'User deleted.'
    redirect_to users_path
  end

  def following
    @title = "Following"
    @user = User.find(params[:id])
    @users = @user.following.paginate(page: params[:page])

    render "show_follow"
  end

  def followers
    @title = "Followers"
    @user = User.find(params[:id])
    @users = @user.followers.paginate(page: params[:page])

    render "show_follow"
  end

  def user_params
    # adminはパラメータに含めない(セキュリティ対策)
    params
      .require(:user)
      .permit(:name, :email, :password, :password_confirmation)
  end
  private :user_params

  # 開こうとしているページが自分のものどうかを確認
  def correct_user
    @user = User.find(params[:id])

    # 自分以外のページを開こうとしていたらHOMEに戻す
    redirect_to root_path unless current_user?(@user)
  end
  private :correct_user

  # 管理者かどうか確認
  def admin_user
    # 管理者でなければHOMEに戻す
    redirect_to root_path unless current_user.admin?
  end
  private :admin_user
end
