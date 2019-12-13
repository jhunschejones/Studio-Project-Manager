class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [:edit, :update, :destroy, :destroy_file]
  before_action :set_files, only: [:edit]

  def index
    @projects = Project.all.active
  end

  def show
    @project = Project.includes(:users).where(id: params[:id]).first
    set_files
  end

  def new
    @project = Project.new
  end

  def edit
  end

  def create
    project = Project.create!(project_params)
    redirect_to project_path(project)
  end

  def update
    if project_params[:title] || project_params[:description]
      @project.update!(title: project_params[:title], description: project_params[:description])
    end

    if project_params[:files]
      @project.files.attach(project_params[:files])
    end

    redirect_to project_path(@project)
  end

  def destroy
    @project.archive!
    redirect_to projects_path
  end

  def destroy_file
    @project.files.find_by_id(params[:file_id]).purge_later
    redirect_to edit_project_path(@project)
  end

  private

  def project_params
    params.require(:project).permit(:title, :description, files: [])
  end

  def set_project
    @project = Project.find(params[:id])
  end

  def set_files
    @files = @project.files.map do |file|
      Project::File.new(
        file.id,
        file.blob.filename.to_s,
        rails_blob_url(file, disposition: "attachment")
      )
    end
  end
end
