class TracksController < ApplicationController
  before_action :set_project_or_redirect
  before_action :set_track, except: [:create]

  def show
  end

  def edit
    @track_version = TrackVersion.new
  end

  def create
    @track = Track.new(track_params.except(:is_completed).merge({project_id: @project.id}))
    @project.reload
    respond_to do |format|
      if @track.save
        format.js
      else
        format.js
      end
    end
  end

  def update
    @track.update(track_params)
    redirect_to project_track_path(@project, @track)
  end

  def destroy
    if current_user.can_delete_tracks?(@project)
      respond_to do |format|
        if @track.destroy
          format.js
          format.html { redirect_to project_path(@project) }
        else
          format.js
          format.html { redirect_to project_path(@project), alert: "Unable to delete track." }
        end
      end
    else
      redirect_to project_path(@project), alert: "You cannot delete tracks."
    end
  end

  private

  def set_track
    @track = Track.includes(track_versions: [:links, :comments]).find(params[:id])
  end

  def track_params
    params.require(:track).permit(:title, :description, :is_completed, :order)
  end
end
