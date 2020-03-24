class ProjectsController < ApplicationController
  before_action :set_project_or_redirect, except: [:index, :new, :create]
  before_action :project_create_or_redirect, only: [:new, :create]

  def index
    @projects = current_user.projects.active.order(:created_at).includes(:users, :tracks, :events)
  end

  def show
  end

  def new
    @project = Project.new
  end

  def edit
    @link = Link.new
    @user = User.new
    @track = Track.new
    @event = Event.new
  end

  def create
    project = Project.create!(project_params)
    UserProject.create!(user_id: current_user.id, project_id: project.id, project_role: UserProject::PROJECT_OWNER)
    redirect_to project_path(project)
  end

  def update
    @project.update!(project_params)
    redirect_to project_path(@project)
  end

  def destroy
    return redirect_to projects_path, notice: "You are not allowed to archive the '#{@project.title}' project" unless current_user.can_archive_project?(@project)
    @project.archive!
    redirect_to projects_path
  end

  private

  def project_params
    params.require(:project).permit(:title, :description)
  end

  def project_create_or_redirect
    redirect_to projects_path, notice: "You are not allowed to create new projects" unless current_user.can_create_projects?
  end
end
