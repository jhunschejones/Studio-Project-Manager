class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def set_project_or_redirect
    @project ||= Project.includes(:tracks, :links, :users, :events, :notifications).find(params[:project_id] || params[:id])
    redirect_to projects_path, notice: "You cannot access that project" unless current_user.can_access_project?(@project)
  end

  # Overwriting the sign_out redirect path method in devise
  # https://github.com/heartcombo/devise/wiki/How-To:-Change-the-redirect-path-after-destroying-a-session-i.e.-signing-out
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
