class ProjectsController < ApplicationController
  before_action :set_project_or_redirect, except: [:index, :new, :create]

  def index
    @projects = current_user.projects.active
  end

  def show
  end

  def new
    redirect_to projects_path, notice: "You are not allowed to create new projects" unless current_user.is_admin_on_any_project?
    @project = Project.new
  end

  def edit
    @link = Link.new
    @user = User.new
  end

  def create
    if current_user.is_admin_on_any_project?
      project = Project.create!(project_params)
      UserProject.create!(user_id: current_user.id, project_id: project.id, role: UserProject::ADMIN)
      redirect_to project_path(project)
    else
      redirect_to projects_path, notice: "You are not allowed to create new projects"
    end
  end

  def update
    if project_params[:title] || project_params[:description]
      @project.update!(title: project_params[:title], description: project_params[:description])
    end

    redirect_to project_path(@project)
  end

  def destroy
    if current_user.is_admin_on?(@project)
      @project.archive!
      redirect_to projects_path
    else
      redirect_to projects_path, notice: "You are not allowed to archive the '#{@project.title}' project"
    end
  end

  private

  def project_params
    params.require(:project).permit(:title, :description)
  end
end
