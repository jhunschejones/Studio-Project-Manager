class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def set_project_or_redirect
    @project ||= Project.includes(:tracks, :links, :users, :events, :notifications).find(params[:project_id] || params[:id])
    redirect_to projects_path, notice: "You cannot access that project" unless current_user.can_access_project?(@project)
  end
end
