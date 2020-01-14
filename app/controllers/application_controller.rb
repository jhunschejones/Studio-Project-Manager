class ApplicationController < ActionController::Base
  before_action :authenticate_user!

  def set_project_or_redirect
    @project ||= Project.includes(:users).find(params[:project_id] || params[:id])
    redirect_to projects_path, notice: "You cannot access this project" unless @project.users.pluck(:id).include?(current_user.id)
  end
end
