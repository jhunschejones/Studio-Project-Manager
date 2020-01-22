class TracksController < ApplicationController
  before_action :set_project_or_redirect
  before_action :set_track, only: [:show, :edit, :update, :destroy]

  def show
  end

  def edit
    @track_version = TrackVersion.new
  end

  def create
    @track = Track.new(
      title: track_params[:title],
      order: track_params[:order],
      project_id: @project.id,
    )

    respond_to do |format|
      if @track.save
        format.js
      else
        format.js
      end
    end
  end

  def update
    @track.update(
      title: track_params[:title],
      is_completed: track_params[:is_completed],
      order: track_params[:order]
    )
    redirect_to project_track_path(@project, @track)
  end

  def destroy
    respond_to do |format|
      if @track.destroy
        format.js
      else
        format.js
      end
    end
  end

  private

  def set_track
    @track = Track.eager_load(track_versions: [:links, :notes]).find(params[:id])
  end

  def track_params
    params.require(:track).permit(:title, :is_completed, :order)
  end
end
