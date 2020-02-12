class TrackVersionsController < ApplicationController
  before_action :set_project_or_redirect
  before_action :track_version_modify_or_redirect, except: [:show]
  before_action :set_track
  before_action :set_track_version, except: [:show, :create]

  def show
    @track_version = TrackVersion.includes(:links, comments: [:user]).find(params[:id])
  end

  def edit
    @link = Link.new
  end

  def create
    @track_version = TrackVersion.new(track_versions_params.merge({track_id: @track.id}))

    respond_to do |format|
      if @track_version.save
        format.js
      else
        format.js
      end
    end
  end

  def update
    @track_version.update(track_versions_params)
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
    params.require(:track_version).permit(:title, :description, :order)
  end

  def set_track
    @track = Track.find(params[:track_id])
  end

  def set_track_version
    @track_version = TrackVersion.includes(:links, comments: [:user]).find(params[:id])
  end

  def track_version_modify_or_redirect
    redirect_to project_path(@project), alert: "You cannot modify that track version." unless current_user.can_manage_track_versions?(@project)
  end
end
