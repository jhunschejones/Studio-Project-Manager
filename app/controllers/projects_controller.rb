class ProjectsController < ApplicationController
  before_action :set_project_or_redirect, except: [:index]

  def index
    @projects = Project.all.active
  end

  def show
  end

  def new
    @project = Project.new
  end

  def edit
    @link = Link.new
  end

  def create
    project = Project.create!(project_params)
    redirect_to project_path(project)
  end

  def update
    if project_params[:title] || project_params[:description]
      @project.update!(title: project_params[:title], description: project_params[:description])
    end

    redirect_to project_path(@project)
  end

  def destroy
    @project.archive!
    redirect_to projects_path
  end

  private

  def project_params
    params.require(:project).permit(:title, :description)
  end
end
