class ProjectsController < ApplicationController

  def index
    @projects = Project.all
  end

  def show
    @project = Project.find(params[:id])
  end

  def edit
  end

  def delete
  end

  def create
  end

  def update
  end

  def destroy
  end
end
