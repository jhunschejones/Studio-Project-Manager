class ProjectsController < ApplicationController

  def index
    @projects = Project.all
  end

  def show
    @project = Project.find(params[:id])
  end

  def edit
    @project = Project.find(params[:id])
  end

  def delete
  end

  def create
  end

  def update
    project = Project.find(params[:id])
    project.update(project_params)
    redirect_to project_path(project)
  end

  def destroy
  end

  private

  def project_params
    params.require(:project).permit(:name, :description)
  end
end
