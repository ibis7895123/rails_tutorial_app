class UsersController < ApplicationController
  def show
    @user = User.find(params[:id])
    # 以下を埋め込むとコンソールでその時点のデバッグができる
    # debugger
  end

  def new; end
end
