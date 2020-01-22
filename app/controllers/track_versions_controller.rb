class TrackVersionsController < ApplicationController
  before_action :set_project_or_redirect
  before_action :set_track
  before_action :set_track_version, except: [:create]

  def show
  end

  def edit
  end

  def create
    @track_version = TrackVersion.new(
      name: track_versions_params[:name],
      order: track_versions_params[:order],
      track_id: @track.id,
    )

    respond_to do |format|
      if @track_version.save
        format.js
      else
        format.js
      end
    end
  end

  def update
    @track_version.update(
      name: track_versions_params[:name],
      order: track_versions_params[:order],
    )
    redirect_to project_track_track_version_path(@project, @track, @track_version)
  end

  def destroy
    respond_to do |format|
      if @track_version && @track_version.destroy
        format.js
      else
        format.js
      end
    end
  end

  private

  def track_versions_params
    params.require(:track_version).permit(:name, :order)
  end

  def set_track
    @track = Track.find(params[:track_id])
  end

  def set_track_version
    @track_version = TrackVersion.find(params[:id])
  end
end
