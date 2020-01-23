class CommentsController < ApplicationController
  before_action :set_project_or_redirect
  before_action :set_track_and_track_version, only: [:new, :create]
  before_action :set_comment, except: [:new, :create]

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
    if current_user.can_manage_resource?(@comment)
      @comment.update!(comment_params)
    else
      flash[:notice] = "You cannot modify that comment."
    end

    redirect_to_resource
  end

  def destroy
    if current_user.can_manage_resource?(@comment)
      @comment.destroy
    else
      flash[:notice] = "You cannot destroy that comment."
    end

    redirect_to_resource
  end

  private

  def comment_params
    params.require(:comment).permit(:title, :content)
  end

  def redirect_to_resource
    if @comment.commentable_type == "TrackVersion"
      track_version = TrackVersion.eager_load(:track).find(@comment.commentable_id)
      redirect_to project_track_track_version_path(@project, track_version.track, track_version)
    else
      raise "Commentable path not implimented for '#{@comment.commentable_type}'"
    end
  end

  def set_track_and_track_version
    @track = Track.find(params[:track_id])
    @track_version = TrackVersion.includes(:links, comments: [:user]).find(params[:track_version_id])
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end
end
