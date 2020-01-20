class UsersController < ApplicationController
  before_action :set_project_or_redirect, except: [:show]

  def show
    if params[:id] != current_user.id.to_s
      redirect_to user_path(current_user.id)
    end

    @user = current_user
  end

  def add_to_project
    @user = User.where(email: user_params[:email]).first || begin
      new_user_name = user_params[:name].strip
      new_user_name = "New User" if new_user_name.empty?
      User.invite!({email: user_params[:email].strip, name: new_user_name}, current_user)
    end

    @user_project = UserProject.new(
      project_id: @project.id,
      user_id: @user.id
    )

    respond_to do |format|
      if @user_project.save
        format.js
      else
        format.js
      end
    end
  end

  def remove_from_project
    @user_project = UserProject.where(
      user_id: params[:user_id],
      project_id: params[:project_id]
    ).first

    if @user_project.project_role != UserProject::PROJECT_OWNER || current_user.can_manage_project_owners?(@project)
      respond_to do |format|
        if @user_project.destroy
          format.js
        else
          format.js
        end
      end
    else
      redirect_to edit_project_path(@project, anchor: "users"), notice: "You cannot remove a project owner"
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :name)
  end
end
