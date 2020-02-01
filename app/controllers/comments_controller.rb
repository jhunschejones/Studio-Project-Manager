class CommentsController < ApplicationController
  before_action :set_project_or_redirect
  before_action :set_comment_or_redirect, except: [:new, :create]
  before_action :set_commented_on_resource

  def new
    @comment = Comment.new

    if @track_version
      @form_url = project_track_track_version_comments_path(@project, @track_version.track, @track_version)
    else
      raise "Unrecognized commentable type"
    end
  end

  def edit
  end

  def create
    @comment = Comment.new(comment_params.merge({user_id: current_user.id}))

    if @track_version
      @track_version.comments << @comment
      @track_version.save!
    else
      raise "Unrecognized commentable type"
    end
    redirect_to_resource
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

  def set_commented_on_resource
    if params[:track_version_id] || @comment.commentable_type == "TrackVersion"
      set_track_version
    else
      raise "Comments not implimented for '#{@comment.commentable_type}'"
    end
  end

  def redirect_to_resource
    raise "Commentable path not implimented for '#{@comment.commentable_type}'" unless params[:track_version_id] || @comment.commentable_type == "TrackVersion"
    set_track_version
    redirect_to project_track_track_version_path(@project, @track_version.track, @track_version)
  end

  def set_comment_or_redirect
    @comment = Comment.find(params[:id])
    unless current_user.can_manage_user_owned_resource?(@comment)
      flash[:alert] = "You cannot modify that comment."
      redirect_to_resource
    end
  end

  def set_track_version
    track_version_id = params[:track_version_id] || @comment.try(:commentable_id)
    @track_version = TrackVersion.eager_load(:track).find(track_version_id)
  end
end
