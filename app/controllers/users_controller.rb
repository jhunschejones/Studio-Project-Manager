class UsersController < ApplicationController
  before_action :authenticate_user!

  def show
    if params[:id] != current_user.id.to_s
      redirect_to user_path(current_user.id)
    end

    @user = User.find(params[:id])
  end
end
