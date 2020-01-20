class TracksController < ApplicationController
  before_action :set_project_or_redirect
  before_action :set_track, only: [:edit, :update, :destroy]

  def edit
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
    redirect_to edit_project_path(@project, anchor: "tracks")
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
    @track = Track.find(params[:id])
  end

  def track_params
    params.require(:track).permit(:title, :is_completed, :order)
  end
end
