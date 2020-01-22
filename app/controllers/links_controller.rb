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
    @project.links << @link

    respond_to do |format|
      if @project.save
        format.js
      else
        format.js
      end
    end
  end

  def update
    @link.update(text: link_params[:text], url: link_params[:url])
    redirect_to edit_project_path(@project, anchor: "links")
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
    link = Link.find(params[:id])
    @link = current_user.can_manage_resource?(link) ? link : nil
  end
end
