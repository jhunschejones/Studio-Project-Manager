class LinksController < ApplicationController
  before_action :set_project_or_redirect
  before_action :set_link, only: [:edit, :update, :destroy]

  def edit
  end

  def create
    @link = Link.new(
      text: link_params[:text],
      url: link_params[:url],
      user_id: current_user.id
    )

    if params[:track_version_id]
      @track_version = TrackVersion.find(params[:track_version_id])
      resource = @track_version
    else
      resource = @project
    end

    resource.links << @link

    respond_to do |format|
      if resource.save
        format.js
      else
        format.js
      end
    end
  end

  def update
    @link.update(text: link_params[:text], url: link_params[:url])
    redirect_to_resource
  end

  def destroy
    respond_to do |format|
      if @link && @link.destroy
        format.js
      else
        format.js
      end
    end
  end

  private

  def link_params
    params.require(:link).permit(:text, :url, :link_for_class, :link_for_id)
  end

  def set_link
    @link = Link.find(params[:id])
    redirect_to project_path(@project), alert: "You cannot modify that link." unless current_user.can_manage_user_owned_resource?(@link)
  end

  def redirect_to_resource
    if @link.linkable_type == "TrackVersion"
      track_version = TrackVersion.eager_load(:track).find(@link.linkable_id)
      redirect_to project_track_track_version_path(@project, track_version.track, track_version)
    elsif @link.linkable_type == "Project"
      redirect_to edit_project_path(@project, anchor: "links")
    else
      raise "Linkable resource path not implemented for '#{@link.linkable_type}'"
    end
  end
end
