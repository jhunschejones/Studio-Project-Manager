class UsersController < ApplicationController
  before_action :set_project_or_redirect, except: [:show]

  def show
    if params[:id] != current_user.id.to_s
      redirect_to user_path(current_user.id), alert: "You cannot view other user's profiles."
    end

    @user = current_user
  end

  def add_to_project
    @email = user_params[:email].strip

    @user = User.where(email: @email).first || begin
      new_user_name = user_params[:name].try(:strip)
      new_user_name = "New User" if new_user_name.blank?
      User.invite!({email: @email, name: new_user_name}, current_user)
    end

    @user_project = UserProject.new(
      project_id: @project.id,
      user_id: @user.id
    )

    respond_to do |format|
      if @user_project.save
        UserMailer.invite_to_project(@user.id, @project.id, current_user.id).deliver_later unless @user.invitation_token
        format.js
      else
        format.js
      end
    end
  end

  def remove_from_project
    @user_project = UserProject.where(user_id: params[:user_id], project_id: params[:project_id]).first
    return redirect_to edit_project_path(@project, anchor: "users"), notice: "User not found on this project" unless @user_project

    unless @user_project.project_role != UserProject::PROJECT_OWNER || current_user.can_manage_project_owners?(@project)
      return redirect_to edit_project_path(@project, anchor: "users"), notice: "You cannot remove a project owner"
    end

    respond_to do |format|
      if @user_project.destroy
        format.js
      else
        format.js
      end
    end
  end

  def update_preferences
    if params[:user_id] != current_user.id.to_s
      return redirect_to edit_user_registration_path, alert: "You cannot modify another user's prefrences."
    end

    @user_project = UserProject.where(
      user_id: params[:user_id],
      project_id: params[:project_id]
    ).first

    @user_project.receive_notifications = params[:button] == "Subscribe"

    respond_to do |format|
      if @user_project.save
        format.js
      else
        format.js
      end
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :name)
  end
end
