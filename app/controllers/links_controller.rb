class LinksController < ApplicationController
  before_action :set_project_or_redirect
  before_action :set_link, only: [:edit, :update, :destroy]

  def edit
  end

  def create
    @link = Link.new(
      text: link_params[:text],
      url: link_params[:url],
      link_for_class: "Project",
      link_for_id: @project.id,
      user_id: current_user.id
    )

    respond_to do |format|
      if @link.save
        format.js
      else
        format.js
      end
    end
  end

  def update
    @link.update(text: link_params[:text], url: link_params[:url])
    redirect_to edit_project_path(@project)
  end

  def destroy
    respond_to do |format|
      if @link.destroy
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
    @link = Link.where(id: params[:id], user_id: current_user.id).first
  end
end