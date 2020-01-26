class CommentsController < ApplicationController
  before_action :set_project_or_redirect
  before_action :set_comment_or_redirect, except: [:new, :create]
  before_action :set_track, only: [:new, :create]
  before_action :set_track_version, only: [:new, :create]

  def new
    @comment = Comment.new
  end

  def edit
  end

  def create
    new_comment = Comment.new(comment_params.merge({user_id: current_user.id}))

    @track_version.comments << new_comment
    @track_version.save!

    redirect_to project_track_track_version_path(@project, @track, @track_version)
  end

  def update
    @comment.update!(comment_params)
    redirect_to_resource
  end

  def destroy
    @comment.destroy
    redirect_to_resource
  end

  private

  def comment_params
    params.require(:comment).permit(:title, :content)
  end

  def set_comment_or_redirect
    @comment = Comment.find(params[:id])
    unless current_user.can_manage_resource?(@comment)
      flash[:alert] = "You cannot modify that comment."
      redirect_to_resource
    end
  end

  def set_track
    raise "Comments not implimented yet for this resource" if !params[:track_id]
    @track = Track.find(params[:track_id])
  end

  def set_track_version
    raise "Comments not implimented yet for this resource" if !params[:track_version_id]
    @track_version = TrackVersion.includes(:links, comments: [:user]).find(params[:track_version_id])
  end

  def redirect_to_resource
    if @comment.commentable_type == "TrackVersion"
      track_version = TrackVersion.eager_load(:track).find(@comment.commentable_id)
      redirect_to project_track_track_version_path(@project, track_version.track, track_version)
    else
      raise "Commentable path not implimented for '#{@comment.commentable_type}'"
    end
  end
end
